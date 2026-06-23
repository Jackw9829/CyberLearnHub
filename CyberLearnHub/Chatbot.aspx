<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chatbot.aspx.cs"
         Inherits="CyberLearnHub.Chatbot" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>CyberBot &mdash; CyberLearn Hub</title>
    <style>
        .chat-page {
            display: flex;
            flex-direction: column;
            height: calc(100vh - 120px);
            max-width: 820px;
            margin: 0 auto;
            padding: 24px 24px 0;
        }

        .chat-page-head {
            display: flex;
            align-items: center;
            gap: 14px;
            padding-bottom: 18px;
            border-bottom: 1px solid var(--cyber-border);
            flex-shrink: 0;
        }

        .chat-head-icon {
            width: 46px;
            height: 46px;
            background: rgba(0,212,255,0.08);
            border: 1px solid rgba(0,212,255,0.3);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            color: var(--cyber-accent);
            flex-shrink: 0;
        }

        .chat-head-info { flex: 1; }

        .chat-head-name {
            font-family: 'Rajdhani', sans-serif;
            font-size: 20px;
            font-weight: 700;
            color: var(--cyber-accent);
            letter-spacing: 1px;
        }

        .chat-head-sub {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
            margin-top: 2px;
        }

        .chat-online-pill {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            background: rgba(0,255,157,0.06);
            border: 1px solid rgba(0,255,157,0.25);
            border-radius: 20px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent2);
        }

        .chat-online-dot {
            width: 7px;
            height: 7px;
            background: var(--cyber-accent2);
            border-radius: 50%;
            box-shadow: 0 0 6px var(--cyber-accent2);
            animation: pulse 1.5s ease-in-out infinite;
        }

        .chat-msgs {
            flex: 1;
            overflow-y: auto;
            padding: 20px 0;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .chat-msgs::-webkit-scrollbar { width: 4px; }
        .chat-msgs::-webkit-scrollbar-thumb { background: var(--cyber-border); border-radius: 4px; }

        .msg-row {
            display: flex;
            gap: 10px;
            align-items: flex-end;
            animation: msg-in 0.2s ease both;
        }

        .msg-row.user { flex-direction: row-reverse; }

        @keyframes msg-in {
            from { opacity: 0; transform: translateY(8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .msg-av {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .msg-row.bot  .msg-av { background: rgba(0,212,255,0.1);  border: 1px solid var(--cyber-accent);  color: var(--cyber-accent); }
        .msg-row.user .msg-av { background: rgba(0,255,157,0.1);  border: 1px solid var(--cyber-accent2); color: var(--cyber-accent2); }

        .msg-bubble {
            max-width: 68%;
            padding: 12px 16px;
            font-size: 14px;
            line-height: 1.6;
            border-radius: 12px;
            word-wrap: break-word;
        }

        .msg-row.bot .msg-bubble {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-bottom-left-radius: 3px;
            color: var(--cyber-text);
        }

        .msg-row.user .msg-bubble {
            background: rgba(0,212,255,0.1);
            border: 1px solid rgba(0,212,255,0.25);
            border-bottom-right-radius: 3px;
            color: var(--cyber-heading);
        }

        .msg-dots { display: flex; gap: 5px; padding: 4px 0; align-items: center; }
        .msg-dots span {
            width: 7px; height: 7px;
            background: var(--cyber-accent);
            border-radius: 50%;
            animation: dot-bounce 1s infinite;
        }
        .msg-dots span:nth-child(2) { animation-delay: 0.15s; }
        .msg-dots span:nth-child(3) { animation-delay: 0.30s; }
        @keyframes dot-bounce {
            0%,60%,100% { transform: translateY(0); }
            30%          { transform: translateY(-6px); }
        }

        .chat-input-bar {
            display: flex;
            gap: 10px;
            padding: 16px 0 20px;
            border-top: 1px solid var(--cyber-border);
            flex-shrink: 0;
        }

        .chat-input-bar input {
            flex: 1;
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 12px 16px;
            color: var(--cyber-text);
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }

        .chat-input-bar input:focus { border-color: var(--cyber-accent); }
        .chat-input-bar input::placeholder { color: var(--cyber-muted); }

        .chat-input-bar button {
            background: var(--cyber-accent);
            color: var(--cyber-bg);
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            cursor: pointer;
            transition: background 0.2s;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .chat-input-bar button:hover    { background: #33ddff; }
        .chat-input-bar button:disabled { background: var(--cyber-border); color: var(--cyber-muted); cursor: not-allowed; }

        /* Predefined question chips */
        #chatSuggestions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            padding: 12px 16px 4px;
            border-top: 1px solid var(--cyber-border);
            background: rgba(0, 0, 0, 0.3);
        }
        .chat-chip {
            background: rgba(0, 212, 255, 0.08);
            border: 1px solid rgba(0, 212, 255, 0.35);
            color: var(--cyber-accent);
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.5px;
            padding: 5px 12px;
            border-radius: 20px;
            cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
            white-space: nowrap;
        }
        .chat-chip:hover {
            background: rgba(0, 212, 255, 0.18);
            border-color: var(--cyber-accent);
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="chat-page">

        <!-- Header -->
        <div class="chat-page-head">
            <div class="chat-head-icon">
                <i class="ti ti-robot"></i>
            </div>
            <div class="chat-head-info">
                <div class="chat-head-name">CYBERBOT</div>
                <div class="chat-head-sub">// AI-powered cybersecurity assistant</div>
            </div>
            <div class="chat-online-pill">
                <div class="chat-online-dot"></div>
                Online
            </div>
        </div>

        <!-- Messages -->
        <div class="chat-msgs" id="chatMsgs">
            <div class="msg-row bot">
                <div class="msg-av"><i class="ti ti-robot"></i></div>
                <div class="msg-bubble">
                    Hi! I&#39;m <strong>CyberBot</strong> &#128737;<br />
                    I&#39;m your AI-powered cybersecurity assistant. Ask me anything &mdash;
                    from basic concepts to advanced topics like penetration testing, cryptography,
                    network security, and more.
                </div>
            </div>
        </div>

        <!-- Predefined question chips -->
        <div id="chatSuggestions">
            <button class="chat-chip" onclick="chatChip(this)" type="button">What is phishing?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">How does encryption work?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">What is the OWASP Top 10?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">Explain SQL Injection</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">What is a firewall?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">How does 2FA work?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">What is malware?</button>
            <button class="chat-chip" onclick="chatChip(this)" type="button">Explain zero-day exploits</button>
        </div>

        <!-- Input -->
        <div class="chat-input-bar">
            <input id="chatInput" type="text" placeholder="Ask a cybersecurity question..."
                   autocomplete="off" onkeydown="if(event.key==='Enter'){event.preventDefault();chatSend();}" />
            <button id="btnChatSend" onclick="chatSend()" type="button">
                <i class="ti ti-send"></i> Send
            </button>
        </div>

    </div>

    <script type="text/javascript">
        var chatBusy       = false;
        var chatGuestLimit = 3;
        var chatLoggedIn   = <%= Session["UserID"] != null ? "true" : "false" %>;

        function chatHideSuggestions() {
            var s = document.getElementById('chatSuggestions');
            if (s) s.style.display = 'none';
        }

        function chatChip(btn) {
            var input = document.getElementById('chatInput');
            input.value = btn.textContent || btn.innerText;
            chatHideSuggestions();
            chatSend();
        }

        function chatScroll() {
            var m = document.getElementById('chatMsgs');
            m.scrollTop = m.scrollHeight;
        }

        function chatAddMsg(role, html) {
            var msgs   = document.getElementById('chatMsgs');
            var row    = document.createElement('div');
            row.className = 'msg-row ' + role;

            var av = document.createElement('div');
            av.className = 'msg-av';
            av.innerHTML = role === 'bot'
                ? '<i class="ti ti-robot"></i>'
                : '<i class="ti ti-user"></i>';

            var bubble = document.createElement('div');
            bubble.className = 'msg-bubble';
            bubble.innerHTML = html;

            row.appendChild(av);
            row.appendChild(bubble);
            msgs.appendChild(row);
            chatScroll();
            return row;
        }

        function chatShowTyping() {
            var row = chatAddMsg('bot',
                '<div class="msg-dots"><span></span><span></span><span></span></div>');
            row.id = 'chat-typing';
        }

        function chatFmt(t) {
            return t
                .replace(/&/g,  '&amp;')
                .replace(/</g,  '&lt;')
                .replace(/>/g,  '&gt;')
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                .replace(/`([^`]+)`/g, '<code style="background:rgba(0,212,255,0.1);padding:2px 5px;border-radius:3px;font-size:12px;color:var(--cyber-accent)">$1</code>')
                .replace(/^[\*\-] (.+)$/gm, '<div style="margin:3px 0 3px 8px">&bull; $1</div>')
                .replace(/\n\n/g, '<br /><br />')
                .replace(/\n/g,  '<br />');
        }

        function chatGuestBlocked() {
            if (chatLoggedIn) return false;
            var count = parseInt(sessionStorage.getItem('cb_guest_count') || '0', 10);
            return count >= chatGuestLimit;
        }

        function chatShowGuestLimit() {
            chatAddMsg('bot',
                '<span style="color:var(--cyber-amber)">' +
                '&#9888; You have used your 3 free questions.</span><br />' +
                'Please <a href="<%= ResolveUrl("~/Login.aspx") %>" ' +
                'style="color:var(--cyber-accent);text-decoration:underline;">Log In</a> or ' +
                '<a href="<%= ResolveUrl("~/Register.aspx") %>" ' +
                'style="color:var(--cyber-accent2);text-decoration:underline;">Register</a> ' +
                'to continue chatting.');
            var inp  = document.getElementById('chatInput');
            var send = document.getElementById('btnChatSend');
            inp.disabled  = true;
            send.disabled = true;
            inp.placeholder = 'Login or register to continue...';
        }

        function chatSend() {
            if (chatBusy) return;
            var input = document.getElementById('chatInput');
            var msg   = input.value.replace(/^\s+|\s+$/g, '');
            if (!msg) return;

            if (chatGuestBlocked()) { chatShowGuestLimit(); return; }

            chatHideSuggestions();
            input.value = '';
            chatBusy    = true;
            document.getElementById('btnChatSend').disabled = true;

            if (!chatLoggedIn) {
                var count = parseInt(sessionStorage.getItem('cb_guest_count') || '0', 10);
                sessionStorage.setItem('cb_guest_count', count + 1);
            }

            chatAddMsg('user', chatFmt(msg));
            chatShowTyping();

            fetch('<%= ResolveUrl("~/ChatbotHandler.ashx") %>', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json' },
                body:    JSON.stringify({ message: msg })
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var t = document.getElementById('chat-typing');
                if (t) t.parentNode.removeChild(t);
                chatAddMsg('bot', data.success
                    ? chatFmt(data.reply)
                    : '&#9888; ' + (data.error || data.reply || 'Something went wrong.'));
            })
            .catch(function() {
                var t = document.getElementById('chat-typing');
                if (t) t.parentNode.removeChild(t);
                chatAddMsg('bot', '&#9888; Could not reach the server. Please try again.');
            })
            ['finally'](function() {
                chatBusy = false;
                document.getElementById('btnChatSend').disabled = false;
                document.getElementById('chatInput').focus();
            });
        }

        // Auto-focus input on load
        window.addEventListener('load', function() {
            document.getElementById('chatInput').focus();
        });
    </script>

</asp:Content>
