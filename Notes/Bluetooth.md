
# Bluetooth Controller Notes

Your Bluetooth controller itself is working correctly, but right now it is **not pairable or discoverable**, which means new devices cannot see or pair with your system.

## Key lines from your output

```
Powered: yes          ✅ Bluetooth is ON
Discoverable: no     ❌ Other devices can’t see it
Pairable: no         ❌ New devices can’t pair
Discovering: no      ℹ️ Not scanning right now
```

So nothing is broken — it’s just locked down, which is normal by default.

## Make your system visible & pairable (recommended)

Run these commands:

```bash
bluetoothctl
```

Then inside the prompt:

```
power on
agent on
default-agent
pairable on
discoverable on
```

You should now see:

```
Changing pairable on succeeded
Changing discoverable on succeeded
```

Verify:

```
show
```

Expected:

```
Pairable: yes
Discoverable: yes
```

## Scan and pair a device

Still inside `bluetoothctl`:

```
scan on
```

Wait for your device MAC, then:

```
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

Stop scanning after:

```
scan off
```


