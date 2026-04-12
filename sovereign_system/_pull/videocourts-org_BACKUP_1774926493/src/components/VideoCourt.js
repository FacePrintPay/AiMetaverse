import React, { useRef, useEffect, useState } from 'react';

export default function VideoCourt({ roomId, userName }) {
  const localRef = useRef(null);
  const remoteRef = useRef(null);
  const [status, setStatus] = useState('connecting');
  const [micOn, setMicOn] = useState(true);
  const [camOn, setCamOn] = useState(true);

  useEffect(() => {
    const startVideo = async () => {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { width: 1280, height: 720 },
          audio: true
        });
        if (localRef.current) {
          localRef.current.srcObject = stream;
          setStatus('live');
        }
        // NOTE: Production signaling server goes here
        // For demo: this shows camera works
      } catch (err) {
        console.error('Camera access error:', err);
        setStatus('error');
      }
    };
    startVideo();
    return () => {
      if (localRef.current?.srcObject) {
        localRef.current.srcObject.getTracks().forEach(track => track.stop());
      }
    };
  }, [roomId]);

  const toggleMic = () => {
    const stream = localRef.current?.srcObject;
    if (stream) {
      stream.getAudioTracks().forEach(t => t.enabled = !t.enabled);
      setMicOn(!micOn);
    }
  };

  const toggleCam = () => {
    const stream = localRef.current?.srcObject;
    if (stream) {
      stream.getVideoTracks().forEach(t => t.enabled = !t.enabled);
      setCamOn(!camOn);
    }
  };

  return (
    <div style={{background:'#000',padding:'20px',borderRadius:'12px',color:'white'}}>
      <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(300px,1fr))',gap:'15px',marginBottom:'20px'}}>
        <div>
          <p style={{margin:'5px 0',fontSize:'0.9em',color:'#aaa'}}>You ({userName})</p>
          <video ref={localRef} autoPlay muted playsInline style={{width:'100%',borderRadius:'8px',background:'#111'}} />
        </div>
        <div>
          <p style={{margin:'5px 0',fontSize:'0.9em',color:'#aaa'}}>Judge / Remote Party</p>
          <video ref={remoteRef} autoPlay playsInline style={{width:'100%',borderRadius:'8px',background:'#111'}} />
        </div>
      </div>
      <div style={{display:'flex',gap:'10px',justifyContent:'center',alignItems:'center'}}>
        <button onClick={toggleMic} style={{padding:'12px 24px',borderRadius:'8px',border:'none',background:micOn?'#ef4444':'#10b981',color:'white',fontWeight:'bold',cursor:'pointer'}}>{micOn?'🎤 Mute':'🔇 Unmute'}</button>
        <button onClick={toggleCam} style={{padding:'12px 24px',borderRadius:'8px',border:'none',background:camOn?'#ef4444':'#10b981',color:'white',fontWeight:'bold',cursor:'pointer'}}>{camOn?'📹 Stop Video':'📷 Start Video'}</button>
        <button style={{padding:'12px 24px',borderRadius:'8px',border:'none',background:'#667eea',color:'white',fontWeight:'bold',cursor:'pointer'}}>️ Join Hearing</button>
      </div>
      <p style={{textAlign:'center',marginTop:'10px',fontSize:'0.85em',color:'#888'}}>Status: {status.toUpperCase()} | Room: {roomId}</p>
    </div>
  );
}
