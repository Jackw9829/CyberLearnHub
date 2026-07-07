<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chatbot.aspx.cs"
         Inherits="CyberLearnHub.Chatbot" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>CyberBot &mdash; CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/chatbot.css") %>" />
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
