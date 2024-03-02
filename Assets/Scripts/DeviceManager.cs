using UnityEngine;
public class DeviceManager : MonoBehaviour
{
    [SerializeField]
    [Tooltip("Display Device")]
    DisplayDevice m_device = null;
    
    [SerializeField]
    [Tooltip("Render Capture")]
    RenderCapture m_capture = null;
    
    [SerializeField]
    [Tooltip("Refresh Rate")]
    float m_refreshRate = 0.01f;
    float? m_timer = null;

    public bool IsRefreshDisplayOn {get; private set;} = false;

    void Start()
    {   
        m_device.Connect();
        IsRefreshDisplayOn = true;
    }

    private void OnDestroy()
    {
        m_device.Disconnect();
        IsRefreshDisplayOn = false;
    }
    void Update()
    {
        if(IsRefreshDisplayOn && !Mathf.Approximately(m_refreshRate,0f))
        {
            if(!m_timer.HasValue)
            {
                m_timer = Time.time + m_refreshRate;
            }

            if(Time.time > m_timer)
            {
                m_timer = Time.time + m_refreshRate;
                SendDisplay();
                Debug.Log("send some shit");
            }
        }
    }

    public void SendDisplay()
    {   
        if(m_device.IsConnected)
        {   
            m_device.SendDisplay(m_capture.GetByteArray());
        }
    }

    public void ClearDisplay()
    {   
        if(m_device.IsConnected)
        {
            m_device.ClearDisplay();
        }
    }
    public void SetRefreshDisplay(bool mode)
    {   
        IsRefreshDisplayOn = mode;
    }
    public void SetBrightness(int value)
    {   

        if(m_device.IsConnected)
        {
            m_device.SetBrightness(value);
        }
    }
}
