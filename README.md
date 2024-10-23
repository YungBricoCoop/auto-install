# 🐧 auto-install

A collection of `auto-install` scripts for **Ubuntu**, designed to automate various use cases, including kiosk mode.

### 📁 Current Modes:

- [Kiosk Mode](https://raw.githubusercontent.com/YungBricoCoop/auto-install/refs/heads/main/kiosk/autoinstall.yaml) : A setup for turning Ubuntu into a locked-down, single-purpose system perfect for kiosk setups using tools like Openbox and Google Chrome in kiosk mode.

### 📄 Handling Late-Commands

During the auto-install process, `user-data` is created on first boot, but `late-commands` are executed before user accounts are created. This can cause problems when commands require the presence of a user.

To solve this, the process includes a simple workaround: a script is created in the `late-commands` phase that sets up a service to run at the next boot. Once the user account is created, the service executes another script to complete any remaining tasks. After execution, the service stops itself and deletes its configuration to maintain a clean environment.
