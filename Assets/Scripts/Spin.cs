using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spin : MonoBehaviour
{
    [SerializeField]
    float speed = 0;

    public void Update() {
        transform.Rotate(0,speed*Time.deltaTime,0);
    }
}
