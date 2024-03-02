using UnityEngine; 
 
public class ResolutionController : MonoBehaviour 
{ 
    public int screenWidth = 7; // Set your desired screen width 
    public int screenHeight = 9; // Set your desired screen height 
    public bool fullscreen = true; // Set to true for fullscreen, false for windowed 
 
    void Start() 
    { 
        Screen.SetResolution(screenWidth, screenHeight, fullscreen); 
    } 
} 