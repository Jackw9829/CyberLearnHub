FROM kalilinux/kali-rolling

# Lightweight toolset for CyberLearnHub's network-based labs.
# Add/remove packages here to match what your labs actually require —
# avoid kali-linux-everything, it's several GB and mostly unused.
RUN apt update && apt install -y \
    nmap \
    sqlmap \
    nikto \
    hydra \
    gobuster \
    dirb \
    netcat-traditional \
    curl \
    wget \
    exiftool \
    steghide \
    binwalk \
    john \
    && apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["/bin/bash"]
