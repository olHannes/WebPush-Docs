# Local HTTPS Setup for PWA Development

This document describes how to set up **HTTPS for local development** so that:

* Service Workers
* Push Notifications
* PWA installation

work correctly on **desktop** and **mobile devices (iOS & Android)**.

---

## Prerequisites

* `mkcert`
* `openssl`
* `keytool`

> Payara should **not be running** while the keystore is copied.

---

## 1. Generate Certificates & Keystore

The repository contains two scripts:

* **macOS / Linux:** `scripts/setup-ssl.sh`
* **Windows:** `scripts/setup-ssl.ps1`

Copy the script matching your operating system into the `SmartDeveloper` folder.

---

### 1.1 For localhost (desktop only)

```bash
./setup-ssl.sh
```

or on Windows:

```powershell
.\\setup-ssl.ps1
```

➡ generates certificates for `https://localhost`

---

### 1.2 For access from mobile devices (IP address)

First determine the local IP address of your machine:

* **Windows**

  ```powershell
  ipconfig
  ```

Then run the script with the IP address:

or on Windows:

```powershell
.\\setup-dev-ssl.ps1 <your-ip>
```

➡ generates certificates for `https://<your-ip>`

---

## 2. Configure Payara (Admin Console)

Open the Admin Console:

```
http://localhost:4848
```

---

### 2.1 Configure HTTPS Protocol

Path:

```
Configurations
→ server-config
→ Network Config
→ Protocols
→ http-listener-2
→ SSL
```

Set **only** the following values:

* **Certificate Nickname:** `payara`
* **Key Store:** `config/payara-keystore.jks`
* **Trust Store:** `config/payara-keystore.jks`


---

### 2.3 Restart Payara

Restart te Payara Server in netbeans.

---

## 3. Accessing the Application

### Desktop

```
https://localhost:8181
```

### Mobile devices (iOS / Android)

```
https://<YOUR-IP>:8181
```

Example:

```
https://192.168.178.42:8181
```

---

## 4. Installing the Root CA on Mobile Devices

To make mobile browsers trust the local certificate, the **mkcert Root CA** must be installed.

### Locate the Root CA

```bash
mkcert -CAROOT
```

You will need the file **`rootCA.pem`**.

---

## 4.1 iOS (iPhone / iPad)

1. Transfer `rootCA.pem` to the device (AirDrop, iCloud, Mail)
2. Open the file on the device
3. **Install the profile**
4. Explicitly trust the certificate:

```
Settings
→ General
→ About
→ Certificate Trust Settings
→ Enable "mkcert Development CA"
```

---

## 4.2 Android

1. Copy `rootCA.pem` to the device
2. Settings → Security
3. **Install CA certificate**
4. Select the file
5. Assign a name (e.g. "mkcert Dev CA")

---

## Reverting the HTTPS Configuration Changes

To revert the Payara HTTPS configuration back to its default settings, make the following changes in the Admin Console under:

```
Configurations
→ server-config
→ Network Config
→ Protocols
→ http-listener-2
→ SSL
```

* **Certificate Nickname:** `s1as`
* **Key Store:** ``
* **Trust Store:** ``

### Optional cleanup

* Delete the file `payara-keystore.jks` from `domains/domain1/config/` if it was created by the development setup.

After applying the changes, restart the Payara Server.
