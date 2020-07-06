using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    [SerializeField]
    Vector3 startOff = Vector3.zero;
    [SerializeField]
    Vector3 endOff = Vector3.zero;
    [SerializeField]
    float time = 0;


    Vector3 start;
    Vector3 end;

    void Start() {
        start = transform.position + startOff;
        end = transform.position + endOff;
    }
    void Update() {
        transform.position = Vector3.Lerp(start,end,(1+Mathf.Sin(2*Mathf.PI*Time.time/time))/2);
    }
}
