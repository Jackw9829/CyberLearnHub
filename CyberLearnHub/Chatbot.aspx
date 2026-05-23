<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Chatbot.aspx.cs" Inherits="Chatbot" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>CyberBot - CyberLearn Hub</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: #050d1a;
            color: #c8d8e8;
            font-family: 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        

        .chat-container {
            width: 100%;
            max-width: 700px;
            height: 85vh;
            display: flex;
            flex-direction: column;
            border: 1px solid #0f3460;
            border-radius: 12px;
            overflow: hidden;
            background: #0a1628;
        }

        .chat-header {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            background: #0d1f3c;
            border-bottom: 1px solid #0f3460;
        }
        .header-icon { font-size: 22px; }
        .header-title { font-size: 17px; font-weight: 600; color: #00d4ff; letter-spacing: 1px; }
        .header-sub { font-size: 11px; color: #4a6080; margin-top: 2px; }
        .online-dot {
            width: 9px; height: 9px; background: #00ff88;
            border-radius: 50%; margin-left: auto;
            box-shadow: 0 0 6px #00ff88;
        }

        .chat-messages {
            flex: 1; overflow-y: auto; padding: 16px;
            display: flex; flex-direction: column; gap: 12px;
        }
        .chat-messages::-webkit-scrollbar { width: 4px; }
        .chat-messages::-webkit-scrollbar-thumb { background: #1a3a5c; border-radius: 4px; }

        .msg-row { display: flex; gap: 8px; align-items: flex-end; }
        .msg-row.user { flex-direction: row-reverse; }

        .msg-avatar {
            width: 30px; height: 30px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; flex-shrink: 0;
        }
        .msg-row.bot  .msg-avatar { background: rgba(0,212,255,0.1); border: 1px solid #00d4ff; }
        .msg-row.user .msg-avatar { background: rgba(0,255,136,0.1); border: 1px solid #00ff88; }

        .msg-bubble {
            max-width: 75%; padding: 10px 14px;
            font-size: 13.5px; line-height: 1.6; border-radius: 10px;
        }
        .msg-row.bot .msg-bubble {
            background: #091422; border: 1px solid #0f3460;
            border-bottom-left-radius: 3px; color: #c8d8e8;
        }
        .msg-row.user .msg-bubble {
            background: #0f3460; border: 1px solid #1a4a8a;
            border-bottom-right-radius: 3px; color: #e0f0ff;
        }

        .error-bubble { border-left: 3px solid #ff4757 !important; }

        .typing-dots { display: flex; gap: 4px; padding: 2px 0; }
        .typing-dots span {
            width: 6px; height: 6px; background: #00d4ff;
            border-radius: 50%; animation: bounce 1s infinite;
        }
        .typing-dots span:nth-child(2) { animation-delay: 0.15s; }
        .typing-dots span:nth-child(3) { animation-delay: 0.30s; }
        @keyframes bounce {
            0%,60%,100% { transform: translateY(0); }
            30% { transform: translateY(-6px); }
        }

        .chip-row { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
        .chip {
            font-size: 11px; padding: 4px 10px;
            border: 1px solid #1a3a5c; border-radius: 20px;
            background: transparent; color: #4a6080; cursor: pointer; transition: all 0.2s;
        }
        .chip:hover { border-color: #00d4ff; color: #00d4ff; }

        .chat-input-area {
            padding: 12px 14px; border-top: 1px solid #0f3460;
            display: flex; gap: 8px; background: #0d1f3c;
        }
        .chat-input-area input {
            flex: 1; background: #091422; border: 1px solid #0f3460;
            border-radius: 8px; padding: 9px 13px; color: #c8d8e8;
            font-size: 13.5px; outline: none; transition: border-color 0.2s;
        }
        .chat-input-area input:focus { border-color: #00d4ff; }
        .chat-input-area input::placeholder { color: #2a4060; }
        .chat-input-area button {
            background: #00d4ff; color: #050d1a; border: none;
            border-radius: 8px; padding: 9px 18px; font-size: 13px;
            font-weight: 600; cursor: pointer; transition: background 0.2s;
        }
        .chat-input-area button:hover { background: #00b8e0; }
        .chat-input-area button:disabled { background: #1a3a5c; color: #4a6080; cursor: not-allowed; }

        /* Debug panel - shown only when there is an error detail */
        .debug-box {
            font-size: 10px; font-family: monospace; color: #ff6b6b;
            background: #1a0a0a; border: 1px solid #ff4757;
            border-radius: 4px; padding: 6px 8px; margin-top: 6px;
            white-space: pre-wrap; word-break: break-all; max-height: 100px; overflow-y: auto;
        }
    </style>
</head>
<body>

<div class="chat-container">
    <div class="chat-header">
        <span class="header-icon">&#128737;</span>
        <div>
            <div class="header-title">CyberBot</div>
            <div class="header-sub">CyberLearn Hub &mdash; AI Security Assistant</div>
        </div>
        <div class="online-dot"></div>
    </div>

    <div class="chat-messages" id="chatMessages">
        <div class="msg-row bot">
            <div class="msg-avatar">&#129302;</div>
            <div>
                <div class="msg-bubble">
                    Hi! I'm <strong>CyberBot</strong>, your cybersecurity assistant for CyberLearn Hub.<br><br>
                    Ask me anything about cybersecurity topics!
                </div>
                <div class="chip-row" id="chipRow">
                    <button class="chip" onclick="quickSend('What is phishing?')">What is phishing?</button>
                    <button class="chip" onclick="quickSend('Explain SQL injection')">SQL injection</button>
                    <button class="chip" onclick="quickSend('What is a firewall?')">Firewall basics</button>
                    <button class="chip" onclick="quickSend('What is OWASP Top 10?')">OWASP Top 10</button>
                </div>
            </div>
        </div>
    </div>

    <div class="chat-input-area">
        <input id="userInput" type="text" placeholder="Ask a cybersecurity question..."
               onkeydown="if(event.key==='Enter') sendMessage()" autocomplete="off"/>
        <button id="sendBtn" onclick="sendMessage()">Send</button>
    </div>
</div>

<script>
    var isLoading = false;

    function scrollBottom() {
        var m = document.getElementById('chatMessages');
        m.scrollTop = m.scrollHeight;
    }

    function removeChips() {
        var c = document.getElementById('chipRow');
        if (c) c.remove();
    }

    function appendMessage(role, text, errorDetail) {
        var container = document.getElementById('chatMessages');
        var row = document.createElement('div');
        row.className = 'msg-row ' + role;

        var avatar = document.createElement('div');
        avatar.className = 'msg-avatar';
        // Use HTML entities to avoid encoding issues
        avatar.innerHTML = role === 'bot' ? '&#129302;' : '&#128100;';

        var bubble = document.createElement('div');
        bubble.className = 'msg-bubble' + (errorDetail ? ' error-bubble' : '');
        bubble.innerHTML = formatText(text);

        // Show debug info if available
        if (errorDetail) {
            var debug = document.createElement('div');
            debug.className = 'debug-box';
            debug.textContent = 'DEBUG: ' + errorDetail;
            bubble.appendChild(debug);
        }

        row.appendChild(avatar);
        row.appendChild(bubble);
        container.appendChild(row);
        scrollBottom();
    }

    function appendTyping() {
        var container = document.getElementById('chatMessages');
        var row = document.createElement('div');
        row.className = 'msg-row bot';
        row.id = 'typingRow';

        var avatar = document.createElement('div');
        avatar.className = 'msg-avatar';
        avatar.innerHTML = '&#129302;';

        var bubble = document.createElement('div');
        bubble.className = 'msg-bubble';
        bubble.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';

        row.appendChild(avatar);
        row.appendChild(bubble);
        container.appendChild(row);
        scrollBottom();
    }

    function removeTyping() {
        var t = document.getElementById('typingRow');
        if (t) t.remove();
    }

    function formatText(text) {
        return text
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/`([^`]+)`/g, '<code style="background:rgba(0,212,255,0.1);padding:1px 5px;border-radius:3px;font-size:12px;color:#00d4ff">$1</code>')
            .replace(/^[\*\-] (.+)$/gm, '<div style="margin:2px 0 2px 8px">&bull; $1</div>')
            .replace(/\n\n/g, '<br><br>').replace(/\n/g, '<br>');
    }

    function setLoading(state) {
        isLoading = state;
        document.getElementById('sendBtn').disabled = state;
        document.getElementById('userInput').disabled = state;
    }

    function sendMessage() {
        if (isLoading) return;
        var input = document.getElementById('userInput');
        var message = input.value.trim();
        if (!message) return;

        removeChips();
        input.value = '';
        setLoading(true);
        appendMessage('user', message);
        appendTyping();

        fetch('ChatbotHandler.ashx', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: message })
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            removeTyping();
            if (data.success) {
                appendMessage('bot', data.reply);
            } else {
                // Show error detail so you can debug
                appendMessage('bot', 'Could not get a response.', data.error || data.reply);
            }
        })
        .catch(function(err) {
            removeTyping();
            appendMessage('bot', 'Could not reach ChatbotHandler.ashx. Make sure the file exists in your project.', err.toString());
        })
        .finally(function() {
            setLoading(false);
            input.focus();
        });
    }

    function quickSend(text) {
        document.getElementById('userInput').value = text;
        sendMessage();
    }

    document.getElementById('userInput').focus();
</script>

</body>
</html>
