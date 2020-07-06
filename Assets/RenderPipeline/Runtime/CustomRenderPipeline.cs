using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

public partial class CustomRenderPipeline : RenderPipeline
{
    public enum DisplayMode {
        Standard,
        ShowMotionVectors,
        ShowNoiseTex
    }


    static Material testPost;
    static Material errorMat;
    static Material motionVectorMat;
    static Material coherentNoiseMat;

    static RTHandle motionVectorsRT;
    static RTHandle coherentNoiseRT;
    
    public static DisplayMode displayMode = DisplayMode.Standard;

    public CustomRenderPipeline(Material testPost)
    {
        CustomRenderPipeline.testPost = testPost;
    }

    CommandBuffer buffer = new CommandBuffer { name = "Main Render" };

    CullingResults cullingResults = new CullingResults();

    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    static ShaderTagId[] legacyShaderTagIds = {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };


    public CustomRenderPipeline() {
    }

    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (var camera in cameras)
        {
            Render(context, camera);
        }
    }

    void Render(ScriptableRenderContext context, Camera camera)
    {
        GenMaterials();

        if (!Cull(context, camera))
        {
            return;
        }

        Setup(context, camera);

        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();

        DrawMotionVectors(context,camera);
        DrawCoherentNoise(context,camera);
        DrawVisibleGeometry(context, camera);
        DrawUnsupportedShaders(context, camera);

        // POST
        // ImageEffectBlit(buffer, testPost);
        if(displayMode == DisplayMode.ShowMotionVectors) {
            buffer.Blit(motionVectorsRT,BuiltinRenderTextureType.CameraTarget);
        } else if(displayMode == DisplayMode.ShowNoiseTex) {
            buffer.Blit(coherentNoiseRT,BuiltinRenderTextureType.CameraTarget);
        }


        // DrawGizmos(context, camera);

        Submit(context, camera);

    }

    void GenMaterials() {
		if (errorMat == null)
			errorMat = new Material(Shader.Find("Hidden/InternalErrorShader"));
		if (motionVectorMat == null)
			motionVectorMat = new Material(Shader.Find("Hidden/MotionVectors"));
        if (coherentNoiseMat == null)
            coherentNoiseMat = new Material(Shader.Find("Hidden/CoherentNoise"));
    }

    void Setup(ScriptableRenderContext context, Camera camera)
    {
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample("Render");
        ExecuteBuffer(context, camera);
        context.SetupCameraProperties(camera);
    }

    bool Cull(ScriptableRenderContext context, Camera camera)
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);
            return true;
        }
        return false;
    }

    void Submit(ScriptableRenderContext context, Camera camera)
    {
        buffer.EndSample("Render");
        ExecuteBuffer(context, camera);
        context.Submit();
    }

    void ExecuteBuffer(ScriptableRenderContext context, Camera camera)
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    void DrawVisibleGeometry(ScriptableRenderContext context, Camera camera)
    {
        // OPAQUE
        var sortingSettings = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings) {
        };
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );

        // SKYBOX
        context.DrawSkybox(camera);

        // TRANSPARENT
        // sortingSettings.criteria = SortingCriteria.CommonTransparent;
        // drawingSettings.sortingSettings = sortingSettings;
        // filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        // context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }

    void DrawMotionVectors(ScriptableRenderContext context, Camera camera)
    {
        if(motionVectorsRT == null) {
            // TODO: initailize to 1920x1080 because dynamic scale doesn't work
            motionVectorsRT = RTHandles.Alloc(new Vector2(1920,1080), TextureXR.slices,
            colorFormat: GraphicsFormat.R16G16_SFloat,
            dimension: TextureDimension.Tex2D, useDynamicScale: true, name: "MotionVectors");
            // TODO: MIGHT NOT WORK HERE WE'LL SEE
            buffer.SetGlobalTexture("_MotionVectorsRT",motionVectorsRT);
        }

        buffer.SetRenderTarget(motionVectorsRT);
        buffer.ClearRenderTarget(true,true,Color.black);

        buffer.SetGlobalMatrix("_PreviousVP", CameraMatrixProvider.GetPreviousVPMatrix(camera));
        buffer.SetGlobalMatrix("_NonJitteredVP", CameraMatrixProvider.GetVPMatrix(camera));
        foreach (var component in MotionVectorData.instances)
        {
            buffer.SetGlobalMatrix("_PreviousM", component.previousModelMatrix);
            buffer.DrawMesh(component.mesh, component.transform.localToWorldMatrix, motionVectorMat, 0, 0);

        }
        buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        ExecuteBuffer(context,camera);
    }


    void DrawCoherentNoise(ScriptableRenderContext context, Camera camera) {
        if(coherentNoiseRT == null) {
            // TODO: initailize to 1920x1080 because dynamic scale doesn't work
            coherentNoiseRT = RTHandles.Alloc(new Vector2(1920,1080), TextureXR.slices,
            colorFormat: GraphicsFormat.R32G32B32A32_SInt,
            dimension: TextureDimension.Tex2D, useDynamicScale: true, name: "CoherentNoise");
            // TODO: MIGHT NOT WORK HERE WE'LL SEE
            buffer.SetGlobalTexture("_CoherentNoiseRT",coherentNoiseRT);
        }
        buffer.Blit(coherentNoiseRT,coherentNoiseRT,coherentNoiseMat);
        buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        ExecuteBuffer(context,camera);
    }


    partial void DrawGizmos(ScriptableRenderContext context, Camera camera);
    partial void DrawUnsupportedShaders(ScriptableRenderContext context, Camera camera);


#if UNITY_EDITOR
    partial void DrawGizmos(ScriptableRenderContext context, Camera camera)
    {
        if (Handles.ShouldRenderGizmos())
        {
            context.DrawGizmos(camera, GizmoSubset.PreImageEffects);
            context.DrawGizmos(camera, GizmoSubset.PostImageEffects);
        }
    }
    partial void DrawUnsupportedShaders(ScriptableRenderContext context, Camera camera)
    {
        var drawingSettings = new DrawingSettings(legacyShaderTagIds[0], new SortingSettings(camera))
        {
            overrideMaterial = errorMat
        };

        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }

        var filteringSettings = FilteringSettings.defaultValue;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }
#endif

    static void ImageEffectBlit(CommandBuffer buf, Material material)
    {
        buf.Blit(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget, material);
    }

}