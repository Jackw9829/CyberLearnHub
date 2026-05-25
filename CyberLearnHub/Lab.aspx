<%@ Page Title="Lab - CyberLearnHub" Language="C#" AutoEventWireup="true" CodeBehind="Lab.aspx.cs" Inherits="CyberLearnHub.Lab" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Lab - CyberLearnHub</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%; }
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0f1318; color: #e2e8f0; min-height: 100vh; }

    /* NAVBAR */
    .navbar { background: #141920; border-bottom: 1px solid #2d3748; padding: 0 32px; height: 52px; display: flex; align-items: center; gap: 16px; position: sticky; top: 0; z-index: 100; }
    .navbar-brand { display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 700; color: #63b3ed; text-decoration: none; }
    .navbar-brand span { color: #e2e8f0; }
    .navbar-links { display: flex; gap: 4px; margin-left: 24px; }
    .nav-link { font-size: 13px; color: #718096; text-decoration: none; padding: 6px 12px; border-radius: 6px; transition: background .12s, color .12s; }
    .nav-link:hover { background: rgba(255,255,255,.05); color: #e2e8f0; }
    .nav-link.active { background: rgba(99,179,237,.12); color: #63b3ed; }
    .navbar-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }
    .nav-user { font-size: 12px; color: #718096; padding: 4px 10px; border: 1px solid #2d3748; border-radius: 20px; }
    .nav-btn { font-size: 12px; padding: 5px 14px; border-radius: 6px; border: 1px solid #4a5568; background: #2d3748; color: #e2e8f0; cursor: pointer; text-decoration: none; }
    .nav-btn:hover { background: #3d4a5c; }

    /* PAGE */
    .page-wrap { max-width: 1200px; margin: 0 auto; padding: 28px 24px; }
    .breadcrumb { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #718096; margin-bottom: 12px; }
    .breadcrumb a { color: #63b3ed; text-decoration: none; }
    .page-header h1 { font-size: 20px; font-weight: 600; margin-bottom: 4px; }
    .page-header p  { font-size: 13px; color: #94a3b8; margin-bottom: 20px; }

    /* LAB LAYOUT */
    .lab-wrap { display: grid; grid-template-columns: 300px 1fr; min-height: 580px; border: 1px solid #2d3748; border-radius: 10px; overflow: hidden; }

    /* LEFT PANEL */
    .left-panel { background: #141920; border-right: 1px solid #2d3748; display: flex; flex-direction: column; }
    .lp-header { padding: 16px; border-bottom: 1px solid #2d3748; }
    .lab-badge { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 600; padding: 2px 9px; border-radius: 20px; background: rgba(99,179,237,0.15); color: #63b3ed; margin-bottom: 8px; }
    .lp-header h2 { font-size: 14px; font-weight: 600; color: #e2e8f0; margin-bottom: 4px; }
    .lp-header p  { font-size: 11px; color: #718096; line-height: 1.5; }
    .prog-wrap { padding: 10px 16px; border-bottom: 1px solid #2d3748; }
    .prog-lbl { display: flex; justify-content: space-between; font-size: 11px; color: #718096; margin-bottom: 5px; }
    .prog-bar { height: 3px; background: #2d3748; border-radius: 999px; overflow: hidden; }
    .prog-fill { height: 100%; background: #48bb78; border-radius: 999px; transition: width .4s ease; }
    .tasks-list { flex: 1; overflow-y: auto; }
    .task-item { display: flex; gap: 10px; padding: 10px 16px; cursor: pointer; border-left: 2px solid transparent; transition: background .12s; }
    .task-item:hover { background: rgba(255,255,255,.03); }
    .task-item.active { background: rgba(99,179,237,.07); border-left-color: #63b3ed; }
    .task-num { width: 22px; height: 22px; border-radius: 50%; background: #2d3748; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 600; color: #718096; flex-shrink: 0; margin-top: 1px; transition: background .2s, color .2s; }
    .task-num.done { background: rgba(72,187,120,.2); color: #48bb78; }
    .task-item h4 { font-size: 12px; font-weight: 600; color: #e2e8f0; margin-bottom: 2px; }
    .task-item p  { font-size: 11px; color: #718096; }
    .task-detail { padding: 14px 16px; border-top: 1px solid #2d3748; }
    .task-detail h3 { font-size: 12px; font-weight: 600; color: #e2e8f0; margin-bottom: 6px; }
    .tdesc { font-size: 11px; color: #a0aec0; line-height: 1.65; margin-bottom: 10px; }
    .tdesc code { background: #2d3748; color: #68d391; padding: 0 4px; border-radius: 3px; font-family: Consolas, monospace; font-size: 11px; }
    .hint-box { background: rgba(246,173,85,.1); border: 1px solid rgba(246,173,85,.3); border-radius: 6px; padding: 7px 10px; font-size: 11px; color: #f6ad55; margin-bottom: 10px; display: none; }
    .hint-box.show { display: block; }
    .hint-box code { background: rgba(246,173,85,.15); padding: 0 3px; border-radius: 3px; font-family: Consolas, monospace; }
    .det-btns { display: flex; gap: 6px; margin-bottom: 10px; }
    .btn { padding: 5px 11px; font-size: 11px; border-radius: 6px; border: 1px solid #4a5568; background: #2d3748; color: #e2e8f0; cursor: pointer; transition: background .12s; }
    .btn:hover { background: #3d4a5c; }
    .btn-primary { background: #3182ce; border-color: #2b6cb0; color: #fff; }
    .btn-primary:hover { background: #2b6cb0; }
    .flag-row { display: flex; gap: 6px; }
    .flag-input { flex: 1; font-size: 11px; padding: 5px 9px; border-radius: 6px; border: 1px solid #4a5568; background: #1a202c; color: #e2e8f0; font-family: Consolas, monospace; }
    .flag-input:focus { outline: none; border-color: #63b3ed; }
    .flag-msg { font-size: 11px; margin-top: 5px; display: none; }
    .flag-msg.ok  { color: #48bb78; display: block; }
    .flag-msg.err { color: #fc8181; display: block; }

    /* RIGHT PANEL (TERMINAL) */
    .right-panel { display: flex; flex-direction: column; background: #0d1117; }
    .term-header { padding: 9px 14px; border-bottom: 1px solid #2d3748; display: flex; align-items: center; gap: 8px; background: #161b22; }
    .term-dots { display: flex; gap: 5px; }
    .dot { width: 10px; height: 10px; border-radius: 50%; }
    .dot-r { background: #e05252; } .dot-y { background: #e0a052; } .dot-g { background: #52a852; }
    .term-title { font-size: 11px; color: #718096; font-family: Consolas, monospace; margin-left: 4px; }
    .ai-badge { margin-left: auto; display: inline-flex; align-items: center; gap: 4px; font-size: 10px; font-weight: 600; padding: 2px 8px; border-radius: 20px; background: #1c2a3a; color: #718096; border: 1px solid #2d3748; }
    .ai-badge.on { background: rgba(72,187,120,.15); color: #48bb78; border-color: rgba(72,187,120,.3); }
    .term-body { flex: 1; padding: 12px 14px; font-family: Consolas, 'Courier New', monospace; font-size: 12px; overflow-y: auto; max-height: 360px; line-height: 1.75; }
    .tl { color: #718096; }
    .tl.cmd { color: #e2e8f0; }
    .tl.out { color: #48bb78; }
    .tl.err { color: #fc8181; }
    .tl.sys { color: #63b3ed; }
    .tl.ai  { color: #e2e8f0; white-space: pre-wrap; word-break: break-word; }
    .tl.thinking { color: #718096; font-style: italic; }
    .term-input-row { display: flex; align-items: center; padding: 0 14px 12px; gap: 6px; }
    .prompt-label { font-family: Consolas, monospace; font-size: 12px; color: #48bb78; white-space: nowrap; }
    .term-input { flex: 1; font-family: Consolas, monospace; font-size: 12px; border: none; background: transparent; color: #e2e8f0; outline: none; caret-color: #48bb78; }
    .term-input:disabled { opacity: .4; }
    .term-input::placeholder { color: #4a5568; }
    .quick-cmds { padding: 8px 14px; border-top: 1px solid #2d3748; display: flex; gap: 5px; flex-wrap: wrap; align-items: center; background: #0d1117; }
    .qc { font-family: Consolas, monospace; font-size: 10px; padding: 3px 7px; border-radius: 4px; border: 1px solid #2d3748; background: #161b22; color: #718096; cursor: pointer; transition: all .12s; }
    .qc:hover { border-color: #4a5568; color: #e2e8f0; }
    .api-setup { padding: 10px 14px; border-top: 1px solid #2d3748; display: flex; gap: 6px; align-items: center; background: #0d1117; }
    .api-input { flex: 1; font-size: 11px; padding: 5px 9px; border-radius: 6px; border: 1px solid #2d3748; background: #161b22; color: #e2e8f0; font-family: Consolas, monospace; }
    .api-input:focus { outline: none; border-color: #63b3ed; }
    .api-status { font-size: 10px; font-weight: 600; padding: 3px 8px; border-radius: 20px; white-space: nowrap; }
    .api-status.sim  { background: #1c2a3a; color: #718096; border: 1px solid #2d3748; }
    .api-status.live { background: rgba(72,187,120,.15); color: #48bb78; border: 1px solid rgba(72,187,120,.3); }
    .term-body::-webkit-scrollbar, .tasks-list::-webkit-scrollbar { width: 4px; }
    .term-body::-webkit-scrollbar-thumb, .tasks-list::-webkit-scrollbar-thumb { background: #2d3748; border-radius: 4px; }
    .footer { text-align: center; padding: 24px; font-size: 12px; color: #4a5568; border-top: 1px solid #2d3748; margin-top: 40px; }
  </style>
</head>
<body>

  <!-- NAVBAR -->
  <nav class="navbar">
    <a class="navbar-brand" href="Default.aspx">&#x1F512; <span>CyberLearn<b style="color:#63b3ed">Hub</b></span></a>
    <div class="navbar-links">
      <a class="nav-link" href="Default.aspx">Home</a>
      <a class="nav-link" href="Courses.aspx">Courses</a>
      <a class="nav-link active" href="Lab.aspx">&#x1F9EA; Lab</a>
      <a class="nav-link" href="Dashboard.aspx">Dashboard</a>
    </div>
    <div class="navbar-right">
      <span class="nav-user">&#x1F464; Student</span>
      <a class="nav-btn" href="Login.aspx">Logout</a>
    </div>
  </nav>

  <!-- PAGE CONTENT -->
  <div class="page-wrap">
    <div class="page-header">
      <div class="breadcrumb">
        <a href="Default.aspx">Home</a> &rsaquo;
        <a href="Courses.aspx">Courses</a> &rsaquo;
        <span>Lab 01 &mdash; Network Reconnaissance</span>
      </div>
      <h1>&#x1F6E1; Interactive Lab</h1>
      <p>Complete each task using the terminal. Enable AI mode for intelligent, dynamic responses.</p>
    </div>

    <div class="lab-wrap">

      <!-- LEFT: TASK PANEL -->
      <div class="left-panel">
        <div class="lp-header">
          <div class="lab-badge">&#x1F512; Lab 01</div>
          <h2>Network Reconnaissance</h2>
          <p>Learn to identify open ports and services on a simulated target machine.</p>
        </div>
        <div class="prog-wrap">
          <div class="prog-lbl"><span>Progress</span><span id="progTxt">0 / 4 tasks</span></div>
          <div class="prog-bar"><div class="prog-fill" id="progFill" style="width:0%"></div></div>
        </div>
        <div class="tasks-list">
          <div class="task-item active" onclick="selectTask(0)">
            <div class="task-num" id="tn0">1</div>
            <div><h4>Ping the target</h4><p>Check if host is reachable</p></div>
          </div>
          <div class="task-item" onclick="selectTask(1)">
            <div class="task-num" id="tn1">2</div>
            <div><h4>Basic port scan</h4><p>Discover open ports with nmap</p></div>
          </div>
          <div class="task-item" onclick="selectTask(2)">
            <div class="task-num" id="tn2">3</div>
            <div><h4>Service detection</h4><p>Identify running services</p></div>
          </div>
          <div class="task-item" onclick="selectTask(3)">
            <div class="task-num" id="tn3">4</div>
            <div><h4>Capture the flag</h4><p>Find the hidden flag file</p></div>
          </div>
        </div>
        <div class="task-detail">
          <h3 id="detTitle">Task 1: Ping the target</h3>
          <p class="tdesc" id="detDesc">Verify the target at <code>10.10.10.5</code> is online using the <code>ping</code> command. A successful reply means the host is up.</p>
          <div class="hint-box" id="hintBox">Hint: try <code>ping 10.10.10.5</code> in the terminal.</div>
          <div class="det-btns">
            <button class="btn" onclick="toggleHint()">Show hint</button>
            <button class="btn" onclick="insertCmd()" style="margin-left:auto">Insert cmd</button>
          </div>
          <div class="flag-row">
            <input class="flag-input" id="flagInput" type="text" placeholder="FLAG{...}" />
            <button class="btn btn-primary" onclick="checkFlag()">Submit</button>
          </div>
          <div class="flag-msg" id="flagMsg"></div>
        </div>
      </div>

      <!-- RIGHT: TERMINAL -->
      <div class="right-panel">
        <div class="term-header">
          <div class="term-dots">
            <div class="dot dot-r"></div><div class="dot dot-y"></div><div class="dot dot-g"></div>
          </div>
          <span class="term-title">student@cyberlearnhub ~ bash</span>
          <span class="ai-badge" id="aiBadge">&#x1F916; AI off</span>
        </div>
        <div class="term-body" id="termBody">
          <div class="tl sys">CyberLearnHub Lab Environment v2.0</div>
          <div class="tl sys">Target: 10.10.10.5 &nbsp;|&nbsp; Your IP: 10.10.14.12</div>
          <div class="tl" style="margin-top:6px">Paste your Anthropic API key below to enable AI mode.</div>
          <div class="tl">Without a key the terminal runs in built-in simulation mode.</div>
          <div class="tl">Type <span style="color:#e2e8f0;font-family:Consolas,monospace">help</span> to see available commands.</div>
        </div>
        <div class="term-input-row">
          <span class="prompt-label">student@lab:~$&nbsp;</span>
          <input class="term-input" id="termInput" type="text" placeholder="type a command..." autocomplete="off" spellcheck="false" />
        </div>
        <div class="quick-cmds">
          <span style="font-size:10px;color:#4a5568;margin-right:2px">Quick:</span>
          <span class="qc" onclick="runQ('ping 10.10.10.5')">ping 10.10.10.5</span>
          <span class="qc" onclick="runQ('nmap 10.10.10.5')">nmap 10.10.10.5</span>
          <span class="qc" onclick="runQ('nmap -sV 10.10.10.5')">nmap -sV</span>
          <span class="qc" onclick="runQ('ls')">ls</span>
          <span class="qc" onclick="runQ('cat flag.txt')">cat flag.txt</span>
          <span class="qc" onclick="runQ('help')">help</span>
          <span class="qc" onclick="runQ('clear')">clear</span>
        </div>
        <div class="api-setup">
          <span style="font-size:14px;color:#718096">&#x1F511;</span>
          <input class="api-input" id="apiKeyInput" type="password" placeholder="sk-ant-... paste Anthropic API key for AI mode" />
          <button class="btn" onclick="setApiKey()">Set</button>
          <span class="api-status sim" id="apiStatus">Simulation</span>
        </div>
      </div>

    </div><!-- /lab-wrap -->
  </div><!-- /page-wrap -->

  <div class="footer">&copy; 2025 CyberLearnHub &mdash; APD2F2511CS(CYB) &mdash; CT050-3-2-WAPP</div>

  <script type="text/javascript">
  // ================================================================
  //  CyberLearnHub Lab.aspx - Standalone (no master page needed)
  //  Simulation mode works immediately, no setup required.
  //  AI mode: paste sk-ant-... key into the bottom bar and click Set.
  //  TODO (DB phase): replace TASKS + SIM_COMMANDS with DB-loaded data.
  // ================================================================

  var TASKS = [
    { title:'Task 1: Ping the target',
      desc:'Verify the target at <code>10.10.10.5</code> is online using the <code>ping</code> command.',
      hint:'Try: <code>ping 10.10.10.5</code>', cmd:'ping 10.10.10.5', flag:'FLAG{HOST_IS_ALIVE}' },
    { title:'Task 2: Basic port scan',
      desc:'Run <code>nmap 10.10.10.5</code> to discover open ports on the target.',
      hint:'Try: <code>nmap 10.10.10.5</code>', cmd:'nmap 10.10.10.5', flag:'FLAG{3_PORTS_OPEN}' },
    { title:'Task 3: Service detection',
      desc:'Use <code>nmap -sV 10.10.10.5</code> to identify software versions on each open port.',
      hint:'Try: <code>nmap -sV 10.10.10.5</code>', cmd:'nmap -sV 10.10.10.5', flag:'FLAG{APACHE_2.4.29}' },
    { title:'Task 4: Capture the flag',
      desc:'SSH credentials found: <strong>guest / guest123</strong> on port 22. Connect and read the flag file.',
      hint:'Try: <code>cat flag.txt</code> after connecting.', cmd:'cat flag.txt', flag:'FLAG{R3C0N_M4ST3R}' }
  ];

  var SIM = {
    'help':[{c:'out',v:'Available commands:'},{c:'tl',v:'  ping <host>       - check reachability'},{c:'tl',v:'  nmap <host>       - basic port scan'},{c:'tl',v:'  nmap -sV <host>   - version scan'},{c:'tl',v:'  cat <file>        - read a file'},{c:'tl',v:'  ls                - list files'},{c:'tl',v:'  whoami            - current user'},{c:'tl',v:'  clear             - clear terminal'},{c:'sys',v:'Tip: enable AI mode with your Anthropic API key.'}],
    'whoami':[{c:'tl',v:'student'}],
    'ls':[{c:'tl',v:'Desktop  Documents  tools  labs'},{c:'tl',v:'flag.txt  notes.txt  readme.md'}],
    'cat flag.txt':[{c:'out',v:'FLAG{R3C0N_M4ST3R}'},{c:'sys',v:'[Task 4 - submit this flag on the left!]'}],
    'cat notes.txt':[{c:'tl',v:'Target: 10.10.10.5'},{c:'tl',v:'Enumerate before exploiting.'}],
    'cat readme.md':[{c:'tl',v:'Welcome to CyberLearnHub Lab 01.'},{c:'tl',v:'Complete all 4 tasks to finish.'}],
    'ping 10.10.10.5':[{c:'sys',v:'PING 10.10.10.5 (10.10.10.5): 56 data bytes'},{c:'tl',v:'64 bytes from 10.10.10.5: icmp_seq=0 ttl=63 time=1.24 ms'},{c:'tl',v:'64 bytes from 10.10.10.5: icmp_seq=1 ttl=63 time=1.18 ms'},{c:'tl',v:'64 bytes from 10.10.10.5: icmp_seq=2 ttl=63 time=1.31 ms'},{c:'tl',v:'3 packets transmitted, 3 received, 0% packet loss'},{c:'out',v:'Host is UP!   Flag: FLAG{HOST_IS_ALIVE}'}],
    'nmap 10.10.10.5':[{c:'sys',v:'Starting Nmap 7.80 (https://nmap.org)'},{c:'tl',v:'PORT     STATE  SERVICE'},{c:'out',v:'22/tcp   open   ssh'},{c:'out',v:'80/tcp   open   http'},{c:'out',v:'443/tcp  open   https'},{c:'sys',v:'3 open ports.   Flag: FLAG{3_PORTS_OPEN}'}],
    'nmap -sv 10.10.10.5':[{c:'sys',v:'Nmap 7.80 - Service Version Detection'},{c:'tl',v:'PORT     STATE  SERVICE   VERSION'},{c:'out',v:'22/tcp   open   ssh       OpenSSH 7.6p1 Ubuntu'},{c:'out',v:'80/tcp   open   http      Apache httpd 2.4.29'},{c:'out',v:'443/tcp  open   ssl/http  Apache httpd 2.4.29'},{c:'sys',v:'Scan done.   Flag: FLAG{APACHE_2.4.29}'}]
  };
  SIM['nmap -sV 10.10.10.5'] = SIM['nmap -sv 10.10.10.5'];

  var AI_PROMPT = 'You are the AI backend of CyberLearnHub, an educational cybersecurity lab simulator. Simulate a Linux terminal.\n\nENVIRONMENT:\n- Student: student@cyberlearnhub\n- Target: 10.10.10.5, Student IP: 10.10.14.12\n- Ports: 22 (OpenSSH 7.6p1), 80 (Apache 2.4.29), 443 (Apache 2.4.29)\n- flag.txt = FLAG{R3C0N_M4ST3R}\n- ping flag = FLAG{HOST_IS_ALIVE}, nmap flag = FLAG{3_PORTS_OPEN}, nmap -sV flag = FLAG{APACHE_2.4.29}\n- SSH: guest / guest123\n\nRULES: Terminal output only (max 10 lines). Include FLAG{} for correct commands. Plain English = short system note. Unknown cmd = bash: <cmd>: command not found. Never break character.';

  var apiKey='', curTask=0, done={}, hintOn=false, busy=false;

  function printLine(cls, txt) {
    var tb=document.getElementById('termBody'), d=document.createElement('div');
    d.className='tl '+cls; d.textContent=txt; tb.appendChild(d); tb.scrollTop=tb.scrollHeight; return d;
  }

  function runSim(raw) {
    var lines=SIM[raw.toLowerCase().trim()];
    if(lines){ for(var i=0;i<lines.length;i++) printLine(lines[i].c,lines[i].v); }
    else { printLine('err','bash: '+raw+': command not found'); printLine('tl',"Type 'help' or enable AI mode."); }
  }

  function runAI(cmd) {
    busy=true; document.getElementById('termInput').disabled=true;
    var t=printLine('thinking','AI is processing...');
    fetch('https://api.anthropic.com/v1/messages',{
      method:'POST',
      headers:{'Content-Type':'application/json','x-api-key':apiKey,'anthropic-version':'2023-06-01','anthropic-dangerous-direct-browser-access':'true'},
      body:JSON.stringify({model:'claude-sonnet-4-20250514',max_tokens:400,system:AI_PROMPT,messages:[{role:'user',content:cmd}]})
    })
    .then(function(r){return r.json();})
    .then(function(data){
      t.remove();
      if(data.content&&data.content[0]&&data.content[0].text){
        data.content[0].text.trim().split('\n').forEach(function(l){printLine('ai',l);});
      } else { printLine('err','AI error: '+((data.error&&data.error.message)||'unknown')); }
    })
    .catch(function(){ t.remove(); printLine('err','AI failed. Falling back to simulation.'); runSim(cmd); })
    .finally(function(){ busy=false; document.getElementById('termInput').disabled=false; document.getElementById('termInput').focus(); });
  }

  function runCmd(raw) {
    if(!raw||!raw.trim()) return;
    printLine('cmd','student@lab:~$ '+raw);
    if(raw.toLowerCase().trim()==='clear'){ document.getElementById('termBody').innerHTML=''; return; }
    apiKey ? runAI(raw) : runSim(raw);
  }

  function runQ(cmd){ if(!busy){ runCmd(cmd); document.getElementById('termInput').focus(); } }

  function setApiKey(){
    var v=document.getElementById('apiKeyInput').value.trim();
    if(v.indexOf('sk-')===0){
      apiKey=v;
      document.getElementById('apiStatus').textContent='AI active';
      document.getElementById('apiStatus').className='api-status live';
      var b=document.getElementById('aiBadge'); b.textContent='\uD83E\uDD16 AI on'; b.className='ai-badge on';
      printLine('sys','AI mode enabled - powered by Claude.');
      printLine('sys','Type commands OR ask questions in plain English.');
    } else { printLine('err','Invalid key. Should start with sk-ant-...'); }
  }

  function selectTask(i){
    curTask=i;
    document.querySelectorAll('.task-item').forEach(function(el,j){el.classList.toggle('active',j===i);});
    var t=TASKS[i];
    document.getElementById('detTitle').textContent=t.title;
    document.getElementById('detDesc').innerHTML=t.desc;
    document.getElementById('hintBox').innerHTML='Hint: '+t.hint;
    document.getElementById('hintBox').classList.remove('show');
    document.getElementById('flagInput').value='';
    document.getElementById('flagMsg').className='flag-msg';
    document.getElementById('flagMsg').textContent='';
    hintOn=false;
  }

  function toggleHint(){ hintOn=!hintOn; document.getElementById('hintBox').classList.toggle('show',hintOn); }
  function insertCmd(){ document.getElementById('termInput').value=TASKS[curTask].cmd; document.getElementById('termInput').focus(); }

  function checkFlag(){
    var val=document.getElementById('flagInput').value.trim().toUpperCase();
    var msg=document.getElementById('flagMsg');
    if(val===TASKS[curTask].flag.toUpperCase()){
      msg.textContent='\u2713 Correct! Task completed.'; msg.className='flag-msg ok';
      done[curTask]=true;
      var tn=document.getElementById('tn'+curTask); tn.textContent='\u2713'; tn.className='task-num done';
      var count=Object.keys(done).length;
      document.getElementById('progFill').style.width=Math.round((count/TASKS.length)*100)+'%';
      document.getElementById('progTxt').textContent=count+' / '+TASKS.length+' tasks';
      printLine('out','[Task '+(curTask+1)+' completed!] '+TASKS[curTask].flag);
    } else { msg.textContent='\u2717 Wrong flag - check terminal output.'; msg.className='flag-msg err'; }
  }

  document.getElementById('termInput').addEventListener('keydown',function(e){
    if(e.key==='Enter'&&!busy){var v=this.value.trim();if(v){runCmd(v);this.value='';}}
  });
  document.getElementById('apiKeyInput').addEventListener('keydown',function(e){
    if(e.key==='Enter') setApiKey();
  });
  </script>

</body>
</html>