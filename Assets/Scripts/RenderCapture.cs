using System;
using System.Runtime.InteropServices;
using UnityEngine;
public class RenderCapture : MonoBehaviour
{
    [SerializeField]
    [Tooltip("Width of Texture")]
    int m_width = 7;
    
    [SerializeField]
    [Tooltip("Height of Texture")]
    int m_height = 9;

    byte[] m_bytes = null;
    int m_lengthOfBytes = 0;
    Texture2D m_capturedTexture = null;


    void Awake()
    {
        m_capturedTexture = new Texture2D(m_width, m_height);
        m_lengthOfBytes = Marshal.SizeOf(typeof(Color32)) * (m_width * m_height);
        // Debug.Log(m_lengthOfBytes);
        m_bytes = new byte[m_lengthOfBytes];
    }

    // Update for Debugging
    // void Update()
    // {
    //     if (Input.GetKeyDown(KeyCode.Space))
    //     {
    //         GetByteArray();
    //         // DebugPixelColor(3, 4, m_width, m_bytes);
    //     }
    // }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {   
        Graphics.Blit(src, dest);
        GetRenderTexturePixels(src);
    }

    void GetRenderTexturePixels(RenderTexture renderTexture)
    {   
        RenderTexture activeRenderTexture = RenderTexture.active;
        RenderTexture.active = renderTexture;
        m_capturedTexture.ReadPixels(new Rect(0,0,m_capturedTexture.width, m_capturedTexture.height),0,0);  
        RenderTexture.active = activeRenderTexture;
    }

    public byte[] GetByteArray()
    {
        Color32[] colors = m_capturedTexture.GetPixels32();

        if(colors != null && colors.Length >0)
        {
            GCHandle handle = default(GCHandle);
            
            try
            {
                handle = GCHandle.Alloc(colors, GCHandleType.Pinned);
                IntPtr ptr = handle.AddrOfPinnedObject();
                Marshal.Copy(ptr, m_bytes, 0, m_lengthOfBytes);
            }

            finally
            {
                if(handle != default(GCHandle))
                    handle.Free();
            }
        }
        return m_bytes;
    } 


    // // Function for Debugging
    // public void DebugPixelColor(int x, int y, int textureWidth, byte[] byteArray)
    // {
    //     int index = y * textureWidth + x;
        
    //     int byteIndex = index * 4;
        
    //     if (byteIndex + 3 < byteArray.Length)
    //     {
    //         byte red = byteArray[byteIndex];
    //         byte green = byteArray[byteIndex + 1];
    //         byte blue = byteArray[byteIndex + 2];
    //         byte alpha = byteArray[byteIndex + 3];
    //         Debug.Log($"Pixel Color at ({x},{y}): R={red}, G={green}, B={blue}, A={alpha}");
    //     }
    //     else
    //     {
    //         Debug.LogError($"Pixel coordinates ({x},{y}) are out of bounds.");
    //     }
    // }

}
