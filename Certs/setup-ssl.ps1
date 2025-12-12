param (
  [string]$Target = "localhost"
)

# ===================================
# Resolve script path
# ===================================
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ==========================
# Configuration
# ==========================
$PayaraDomain = Join-Path $ScriptDir "software\payara6\glassfish\domains\domain1"
$ConfigDir = Join-Path $PayaraDomain "config"
$Keystore = "payara-keystore.jks"
$Alias = "payara"
$Password = "changeit"

Write-Host "SSL Setup for: $Target"
Write-Host "Payara config: $ConfigDir"
Write-Host

# ==========================
# Check dependencies
# ==========================
foreach ($cmd in @("mkcert", "openssl", "keytool")) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Error "$cmd not found"
    exit 1
  }
}

if (-not (Test-Path $ConfigDir)) {
  Write-Error "Payara config directory not found"
  exit 1
}

# ==========================
# mkcert CA
# ==========================
mkcert -install

# ==========================
# Certificate
# ==========================
mkcert $Target

$CertSafe = $Target -replace "\.", "_"

# ==========================
# PEM → PKCS12
# ==========================
openssl pkcs12 -export `
  -in "$Target.pem" `
  -inkey "$Target-key.pem" `
  -out "$CertSafe.p12" `
  -name $Alias `
  -passout pass:$Password

# ==========================
# PKCS12 → JKS
# ==========================
keytool -importkeystore `
  -srckeystore "$CertSafe.p12" `
  -srcstoretype PKCS12 `
  -srcstorepass $Password `
  -destkeystore $Keystore `
  -deststoretype JKS `
  -deststorepass $Password `
  -destkeypass $Password `
  -alias $Alias `
  -noprompt

# ==========================
# Copy to Payara
# ==========================
Copy-Item $Keystore $ConfigDir -Force

Write-Host "Done!"
Write-Host "➡ $ConfigDir\$Keystore"
