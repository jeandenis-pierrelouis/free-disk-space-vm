## Overview

This project is a PowerShell-based disk cleanup workflow designed to reclaim storage on Windows endpoints by using tools that are already built into the operating system. It is intended for environments ranging from startups to enterprise-managed endpoints, with a focus on practical cleanup actions that can be ran manually and automated more deeply over time.

The workflow uses native Windows utilities such as PowerShell, DISM commands, Disk Cleanup of common temporary-file locations. The goal is to reduce dependence on third-party software for routine space recovery while keeping the process easy to understand, support, and extend.


## Problem It Solves

While working in an enterprise environment, Low disk space was a common reoccurrence that hindered business operations on workstations, servers, and VMs. It can degrade performance, interfere with Windows updates, prevent logs from writing properly, disrupt applications, and generate avoidable service desk tickets. From a cost perspective, a computer down due to poor performance of low available space can contribute to $50 an hour. When the season gets busy and coordinating time with end user to clear the space can take days to address. During schedule time with end user, manually trying clearing space can take more than 30 minutes. 

This project provides a repeatable method to recover space from common Windows-generated clutter such as temporary files, Windows Update downloads, search index databases, logs, crash dumps, and component store growth. Instead of cleaning folders one by one, the script brings these tasks together into a single PowerShell-driven process. 


## Why This Project Exists

Many organizations do not need to purchase a separate product just to handle common low-disk-space issues. Windows already includes built-in utilities that can recover meaningful space, but they are often used inconsistently or only during urgent troubleshooting.

This project exists to standardizating a proactive approach. It creates a native-first approach that a technician can run manually today, while also laying the foundation for future automation behind the scenes with minimal end-user interruption.


## Features

- Uses built-in Windows tools.
- Targets common cleanup areas such as temp folders, Windows Update cache, Windows Search index files, logs and dumps, Windows Error Reporting files, and selected vendor cache locations.
- Includes DISM servicing commands to analyze and reduce component store usage.
- Disk Cleanup that can preserve the Recycle Bin while still removing most other cleanup categories.
- Can be run manually in an elevated PowerShell session and later adapted for remote execution or scheduled task. 
- Works as a first-response cleanup workflow before deeper tools such as WinDirStat are needed for visual of what other space that is being used.


## Requirements

To use this workflow, the following are needed:

- The target machine or VM must be powered on.
- PowerShell must be available with administrative privileges.
- The endpoint should remain powered on during execution, especially if cleanup includes component store servicing or search index rebuild operations.
- If `cleanmgr /sagerun` is part of the workflow, a matching `sageset` profile should already be configured on the image or target machine.

## How to Use It

1. Open an elevated PowerShell session on the endpoint, VM, or server.
2. Run the cleanup script to stop relevant services, clear targeted temp and cache locations, remove update downloads, and perform servicing cleanup.
3. Review the resulting free space and determine whether a reboot is required; which is recommended.
4. If the machine is still critically low on space, use a tool such as WinDirStat for deeper analysis of application data, user files, or other uncommon storage consumers.

In practice, this can also be used behind the scenes. The end user may only need a simple notification telling them to keep the machine powered on while maintenance runs.


## What I Learned

One of the biggest takeaways from this project is that common disk space recovery does not always require paid software. Windows already includes utilities that can recover a meaningful amount of space when they are used together in a structured way.

This project also reinforced that native cleanup should be the first step, not the only step. If a machine is still low on space after built-in cleanup finishes, that is the point where deeper inspection tools such as WinDirStat become useful for targeted manual remediation.

## Limitations or Known Issues

- `cleanmgr /sagerun` works best when `sageset` is configured in advance on a golden image or reference machine. Without that preparation, Disk Cleanup selections may need to be configured individually on each machine.
- The current script does not yet include strong error handling or conditional logic for failures such as DISM servicing errors.
- Some files may be locked by active processes, which can limit how much space is recovered until a reboot is completed.
- Rebuilding the Windows Search index can temporarily affect search performance until the index is recreated.
- Native cleanup is effective for common waste, but it does not replace detailed storage analysis when the true problem is large user data, oversized profiles, or application-specific storage use.

## Future Improvements

- Add structured error handling so failures, especially DISM-related issues, can trigger a reboot recommendation or an automatic retry.
- Preconfigure `cleanmgr /sageset` options on a golden image so `cleanmgr /sagerun` can be used immediately on cloned servers and workstations without per-device setup.
- Integrate Active Directory or inventory-based logic to identify machines approaching a defined low-disk-space threshold.
- Trigger a scheduled task or maintenance prompt automatically when a device falls below a target free-space level.
- Add centralized logging and reporting so technicians can track reclaimed space, failures, and reboot-required states.
- Expand the project into a more policy-driven cleanup framework with separate profiles for servers, VDI machines, and end-user workstations.

## Screenshots

Suggested screenshots for this repository:

- PowerShell console before and after cleanup showing reclaimed disk space.
- Output from `Get-Volume` confirming available free space.
- Example `cleanmgr /sageset` configuration with Recycle Bin left unchecked.
- A simple workflow diagram showing notification, cleanup execution, reboot, and validation.

Once images are available, this section can be updated with embedded screenshots and short captions.
