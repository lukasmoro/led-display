using System;
using System.Net;
using System.Net.Sockets;
using UnityEngine;

[CreateAssetMenu(menuName ="Display Device")]

public class DisplayDevice : ScriptableObject
{
    #region Variables;

    [SerializeField]
    [Tooltip("IP address")]
    string m_ipAddress = null;
    
    [SerializeField]
    [Tooltip("Port")]
    int m_port = 80;

    TcpClient m_client = null;
    NetworkStream m_stream = null;

    #endregion

    #region Properties;
    public bool IsConnected{get{return m_client.Connected;}}

    #endregion

    #region Gameplay;
    public void SendDisplay(byte[] bytes)
    {   
        // Debug.Log("bytes passed to output");
        Send(bytes);
    }

    public void ClearDisplay()
    {
        byte c = Convert.ToByte('c');
        byte[] charByte = new byte[]{0,0,0,c};
        Send(charByte);
    }

    public void SetBrightness(int value)
    {
        byte b = Convert.ToByte('b');
        byte bv = Convert.ToByte(value);
        byte[] charByte = new byte[]{bv,0,0,b};
        Send(charByte);
    }
    
    #endregion

    #region Networking
    public void Connect()
    {
        try
        {
            IPAddress ipAddress = Dns.GetHostEntry(m_ipAddress).AddressList[0];
            IPEndPoint ipEndPoint = new IPEndPoint(ipAddress, m_port);
            m_client = new TcpClient();
            m_client.Connect(ipEndPoint);
            m_stream = m_client.GetStream();

            // Debug.Log("stream started");
        }
        catch(Exception e)
        {
            Debug.LogError(e.ToString());
        }
    }

    public void Disconnect()
    {
        try
        {
            m_stream.Close();
            m_client.Close();

            // Debug.Log("stream over");
        }
        catch(Exception e)
        {
            Debug.LogError(e.ToString());
        }
    }

    void Send(byte[] bytes)
    {
        try
        {   
            // Debug.Log("send byte");
            m_stream.Write(bytes, 0, bytes.Length);
        }
        catch(Exception e)
        {
            Debug.LogError(e.ToString());
        }
    }

    #endregion
}

