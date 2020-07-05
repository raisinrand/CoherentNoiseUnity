using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CustomRenderPipeline : RenderPipeline
{
    static Material testPost;
    static Material errorMaterial;
    static Material motionVectorMaterial;
    

    public CustomRenderPipeline(Material testPost)
    {
        CustomRenderPipeline.testPost = testPost;
    }

    const string bufferName = "Main Render";
    CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };

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
        DrawVisibleGeometry(context, camera);
        DrawUnsupportedShaders(context, camera);
        DrawGizmos(context, camera);

        Submit(context, camera);

    }

    void GenMaterials() {
		if (errorMaterial == null)
			errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));
		if (motionVectorMaterial == null)
			motionVectorMaterial = new Material(Shader.Find("Hidden/MotionVectors"));
    }

    void Setup(ScriptableRenderContext context, Camera camera)
    {
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample(bufferName);
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
        buffer.EndSample(bufferName);
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
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );

        // SKYBOX
        context.DrawSkybox(camera);

        // TRANSPARENT
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        // POST
        ImageEffectBlit(buffer, testPost);
        
        // buffer.Blit(BuiltinRenderTextureType.MotionVectors, BuiltinRenderTextureType.CurrentActive);
    }

    void DrawMotionVectors(ScriptableRenderContext context, Camera camera)
    {
        // motionVectorMaterial.SetMatrix("PreviousVP", CameraMatrixProvider.GetPreviousVPMatrix(camera));
        // motionVectorMaterial.SetMatrix("NonJitteredVP", CameraMatrixProvider.GetVPMatrix(camera));

        // buffer.SetRenderTarget(BuiltinRenderTextureType.MotionVectors, BuiltinRenderTextureType.CameraTarget);
        // foreach (var component in DrawMeshWithMotionVectors.instances)
        // {
        //     motionVectorMaterial.SetMatrix("PreviousM", component.previousModelMatrix);
        //     // TODO: no motion vectors rt so just make my own ?!?!?!?!!?!?!?!?!??
        //     buffer.DrawMesh(component.mesh, component.transform.localToWorldMatrix, motionVectorMaterial, 0, 0);

        // }
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
            overrideMaterial = errorMaterial
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
        buf.Blit(BuiltinRenderTextureType.CurrentActive, BuiltinRenderTextureType.CurrentActive, material);
    }

}