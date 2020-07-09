using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static CustomRenderPipeline;

public class RenderControl : MonoBehaviour
{
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.M)) Toggle(DisplayMode.ShowMotionVectors);
        if(Input.GetKeyDown(KeyCode.N)) Toggle(DisplayMode.ShowNoiseTex);
        if(Input.GetKeyDown(KeyCode.B)) Toggle(DisplayMode.ShowNoiseDiff);
        if(Input.GetKeyDown(KeyCode.V)) Toggle(DisplayMode.ShowOutline);
        if(Input.GetKeyDown(KeyCode.P)) CustomRenderPipeline.pauseNoise = !CustomRenderPipeline.pauseNoise;
    }
    void Toggle(DisplayMode displayMode) {
        if(CustomRenderPipeline.displayMode == displayMode)
            CustomRenderPipeline.displayMode = DisplayMode.Standard;
        else CustomRenderPipeline.displayMode = displayMode;
    }
}
