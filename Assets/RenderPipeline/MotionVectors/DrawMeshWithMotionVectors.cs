using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class DrawMeshWithMotionVectors: MonoBehaviour
{
    public static List<DrawMeshWithMotionVectors> instances = new List<DrawMeshWithMotionVectors>();

    public Matrix4x4 previousModelMatrix;

    public Mesh mesh => meshFilter.sharedMesh;
    public Material material => meshRenderer.sharedMaterial;

    MeshFilter meshFilter;
    MeshRenderer meshRenderer;

    void Awake() {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
    }

    void OnEnable() {
        instances.Add(this);
    }
    void OnDisable() {
        instances.Remove(this);
    }
    void Update()
    {
        previousModelMatrix = transform.localToWorldMatrix;
    }
}
