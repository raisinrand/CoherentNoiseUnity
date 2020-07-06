using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static CustomRenderPipeline;

public class RenderControl : MonoBehaviour
{
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.M)) {
            if(CustomRenderPipeline.displayMode == DisplayMode.ShowMotionVectors)
                CustomRenderPipeline.displayMode = DisplayMode.Standard;
            else CustomRenderPipeline.displayMode = DisplayMode.ShowMotionVectors;
        }
        if(Input.GetKeyDown(KeyCode.N)) {
            if(CustomRenderPipeline.displayMode == DisplayMode.ShowNoiseTex)
                CustomRenderPipeline.displayMode = DisplayMode.Standard;
            else CustomRenderPipeline.displayMode = DisplayMode.ShowNoiseTex;
        }
    }
}
