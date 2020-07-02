using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    [SerializeField]
    Vector3 startOff;
    [SerializeField]
    Vector3 endOff;
    [SerializeField]
    float time;


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
