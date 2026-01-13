# Network Configuration Notes

This document captures the steps and observations while configuring Ethernet and Wi-Fi on a laptop, including default gateway adjustments and service management.

## Initial Steps

1. Checked wireless and blocked devices:

```bash
sudo rfkill list
```

2. Reviewed network interfaces:

```bash
ip a
sudo cat /etc/network/interfaces
```

3. Edited network interfaces as needed:

```bash
sudo vim /etc/network/interfaces
```

4. Restarted networking service:

```bash
sudo systemctl restart networking.service
sudo systemctl status networking.service
```

5. Verified Ethernet interface:

```bash
ip a show enp2s0
```

6. Rebooted the system to apply changes:

```bash
sudo reboot
```

## Wi-Fi Management

1. Disabled Wi-Fi:

```bash
sudo nmcli radio wifi off
```

2. Checked Wi-Fi status and interfaces:

```bash
ip a
rfkill list
```

3. Masked `wpa_supplicant` service (to avoid conflicts with manual Ethernet setup):

```bash
sudo systemctl mask wpa_supplicant.service
sudo systemctl status wpa_supplicant.service
```

4. Verified NetworkManager connections:

```bash
nmcli connection
```

## Ethernet Manual Configuration

1. Set static IP, gateway, and DNS for wired connection:

```bash
sudo nmcli connection modify 'Wired connection 1' ipv4.address 192.168.1.62/24
sudo nmcli connection modify 'Wired connection 1' ipv4.gateway 192.168.1.1
sudo nmcli connection modify 'Wired connection 1' ipv4.method manual
sudo nmcli connection modify 'Wired connection 1' ipv4.dns '192.168.1.250'
```

2. Rebooted and verified settings:

```bash
sudo reboot
ip a
```

## Default Gateway Adjustment

* Initially, two default gateways appeared due to both Ethernet and Wi-Fi being enabled.
* Deleted the Ethernet default gateway manually to avoid routing conflicts:

```bash
sudo ip route del default via <ethernet_gateway>
```

## Re-enabling Wi-Fi

1. Unmasked `wpa_supplicant` and checked status:

```bash
sudo systemctl unmask wpa_supplicant.service
sudo systemctl status wpa_supplicant.service
```

2. Enabled Wi-Fi radio:

```bash
sudo nmcli radio wifi on
```

3. Verified that both Ethernet and Wi-Fi are functioning correctly:

```bash
ip a
nmcli connection
```

## Summary

* Ethernet manually configured with static IP, gateway, and DNS.
* Removed duplicate default gateway to avoid conflicts.
* Wi-Fi temporarily disabled during Ethernet configuration.
* `wpa_supplicant` was masked and later unmasked to manage Wi-Fi.
* Both Ethernet and Wi-Fi now operational with correct routing and connectivity.
