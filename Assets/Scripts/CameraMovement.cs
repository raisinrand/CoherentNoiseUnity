using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
	[SerializeField]
    float sensitivityX = 15F;
	[SerializeField]
    float sensitivityY = 15F;

	[SerializeField]
    float minimumX = -360F;
	[SerializeField]
    float maximumX = 360F;

	[SerializeField]
    float minimumY = -60F;
	[SerializeField]
    float maximumY = 60F;

	float rotationX = 0F;
	float rotationY = 0F;
	
	Quaternion originalRotation;


    public float speed;
    
    void Start() {
        originalRotation = transform.rotation;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        bool forward = Input.GetKey(KeyCode.W); 
        bool back = Input.GetKey(KeyCode.S); 
        bool left = Input.GetKey(KeyCode.A); 
        bool right = Input.GetKey(KeyCode.D); 
        bool up = Input.GetKey(KeyCode.E); 
        bool down = Input.GetKey(KeyCode.Q); 
        if(forward) {
            transform.position += transform.forward*speed*Time.deltaTime;
        }
        if(back) {
            transform.position += transform.forward*(-1*speed)*Time.deltaTime;
        }
        if(right) {
            transform.position += transform.right*speed*Time.deltaTime;
        }
        if(left) {
            transform.position += transform.right*(-1*speed)*Time.deltaTime;
        }
        if(up) {
            transform.position += Vector3.up*speed*Time.deltaTime;
        }
        if(down) {
            transform.position += Vector3.up*(-1*speed)*Time.deltaTime;
        }

        // Read the mouse input axis
        rotationX += Input.GetAxis("Mouse X") * sensitivityX;
        rotationY += Input.GetAxis("Mouse Y") * sensitivityY;

        rotationX = ClampAngle (rotationX, minimumX, maximumX);
        rotationY = ClampAngle (rotationY, minimumY, maximumY);
        
        Quaternion xQuaternion = Quaternion.AngleAxis (rotationX, Vector3.up);
        Quaternion yQuaternion = Quaternion.AngleAxis (rotationY, Vector3.left);
        
        transform.localRotation = xQuaternion * yQuaternion * originalRotation;
    }
	
	public static float ClampAngle (float angle, float min, float max)
	{
		if (angle < -360F)
			angle += 360F;
		if (angle > 360F)
			angle -= 360F;
		return Mathf.Clamp (angle, min, max);
	}
}
