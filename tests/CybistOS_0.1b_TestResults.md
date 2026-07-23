\# CybistOS 0.1b Test Results



\## Build



\- Base: Windows 11 Pro 25H2

\- Build type: Component-removal test

\- VM platform: Hyper-V

\- VM generation: 2

\- RAM: 8 GB

\- Virtual processors: 4

\- Virtual disk: Dynamic VHDX

\- Secure Boot: Enabled

\- TPM: Enabled



\## Changes



\- Retained unattended installation from CybistOS 0.1a

\- Removed 52 NTLite components

\- NTLite compatibility protections enabled

\- Only green-rated components selected for removal

\- Core gaming, update, security, networking, and driver components retained



\## Initial Results



\- Custom ISO booted successfully: Pass

\- Windows Setup launched successfully: Pass

\- Installation reached destination-drive selection: Pass



\## Pending Tests



\- Complete installation

\- Confirm local Ryan account

\- Confirm automatic login

\- Confirm Microsoft account setup is skipped

\- Confirm Windows Update works

\- Confirm Defender works

\- Confirm Microsoft Store works

\- Confirm WinGet works

\- Confirm networking and audio work

\- Record idle RAM and process count

\- Run SFC and DISM health checks



\## Result



CybistOS 0.1b passed initial boot testing. Full compatibility testing remains pending.

