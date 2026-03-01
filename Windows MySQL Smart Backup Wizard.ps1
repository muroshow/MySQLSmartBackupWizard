{\rtf1\ansi\ansicpg1254\cocoartf2867
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # UTF-8 Deste\uc0\u287 i\
$OutputEncoding = [System.Text.Encoding]::UTF8\
\
# --- D\uc0\u304 L VE MET\u304 N AYARLARI ---\
$Culture = Get-Culture\
if ($Culture.Name -like "tr*") \{\
    $L_TITLE = "Windows MySQL AKILLI YEDEKLEME S\uc0\u304 H\u304 RBAZI \u55358 \u56793 \u8205 \u9794 \u65039 "\
    $L_STEP_CTRL = "Sistem kontrolleri yap\uc0\u305 l\u305 yor..."\
    $L_ERROR_NOT_FOUND = "\uc0\u10060  HATA: MySQL (mysqldump) bulunamad\u305 !"\
    $L_PWD_PROMPT = " root \uc0\u351 ifresini girin"\
    $L_PWD_HIDDEN = "(Gizli)"\
    $L_CONN_OK = " \uc0\u9989  Ba\u287 lant\u305  ba\u351 ar\u305 l\u305 !"\
    $L_CONN_INFO = " \uc0\u55356 \u57104  Dinamik Ba\u287 lant\u305 :"\
    $L_SELECT_DB = "Yedeklenecek Veritaban\uc0\u305 n\u305  Se\'e7in:"\
    $L_FULL_BACKUP = "HEPS\uc0\u304 N\u304  YEDEKLE"\
    $L_CHOICE = "Se\'e7iminiz"\
    $L_COMPRESS_PROMPT = "\uc0\u55357 \u56550  S\u305 k\u305 \u351 t\u305 rma Se\'e7ene\u287 i"\
    $L_COMPRESS_ASK = " Yedek dosyas\uc0\u305  ZIP olarak s\u305 k\u305 \u351 t\u305 r\u305 ls\u305 n m\u305 ? (e/h): "\
    $L_STEP_START = "Yedekleme i\uc0\u351 lemi ba\u351 lat\u305 ld\u305 ..."\
    $L_STEP_ZIP = "Dosyalar s\uc0\u305 k\u305 \u351 t\u305 r\u305 l\u305 yor..."\
    $L_SUCCESS = "\uc0\u55357 \u56960  \u304 \u350 LEM BA\u350 ARIYLA TAMAMLANDI!"\
    $L_SAVE_DIR = "\uc0\u55357 \u56525  Kay\u305 t Dizini:"\
    $L_FILE_NAME = "\uc0\u55357 \u56510  Yedek dosyan\u305 z \u351 u isimle olu\u351 turulmu\u351 tur:"\
    $L_ERROR_FAIL = "\uc0\u10060  HATA: Yedekleme ba\u351 ar\u305 s\u305 z!"\
    $L_EXIT = "Kapatmak i\'e7in Enter'a bas\uc0\u305 n..."\
    $L_DEV = "Geli\uc0\u351 tirici:"\
\} else \{\
    $L_TITLE = "Windows MySQL SMART BACKUP WIZARD \uc0\u55358 \u56793 \u8205 \u9794 \u65039 "\
    $L_STEP_CTRL = "Running system checks..."\
    $L_ERROR_NOT_FOUND = "\uc0\u10060  ERROR: MySQL (mysqldump) not found!"\
    $L_PWD_PROMPT = " Enter root password"\
    $L_PWD_HIDDEN = "(Hidden)"\
    $L_CONN_OK = " \uc0\u9989  Connection successful!"\
    $L_CONN_INFO = " \uc0\u55356 \u57104  Dynamic Connection:"\
    $L_SELECT_DB = "Select Database to Backup:"\
    $L_FULL_BACKUP = "BACKUP ALL"\
    $L_CHOICE = "Your Choice"\
    $L_COMPRESS_PROMPT = "\uc0\u55357 \u56550  Compression Option"\
    $L_COMPRESS_ASK = " Compress backup as ZIP? (y/n): "\
    $L_STEP_START = "Backup process started..."\
    $L_STEP_ZIP = "Compressing files..."\
    $L_SUCCESS = "\uc0\u55357 \u56960  PROCESS COMPLETED SUCCESSFULLY!"\
    $L_SAVE_DIR = "\uc0\u55357 \u56525  Save Directory:"\
    $L_FILE_NAME = "\uc0\u55357 \u56510  Your backup file has been created as:"\
    $L_ERROR_FAIL = "\uc0\u10060  ERROR: Backup failed!"\
    $L_EXIT = "Press Enter to close..."\
    $L_DEV = "Developer:"\
\}\
\
# --- RENKLER (ANSI) ---\
$E = [char]27\
$GREEN = "$E[0;32m"; $RED = "$E[0;31m"; $CYAN = "$E[0;36m"; $WHITE = "$E[1;37m"\
$BOLD_WHITE = "$E[1;97m"; $GRAY = "$E[0;90m"; $ORANGE = "$E[0;33m"\
$LINKEDIN_BLUE = "$E[1;34m"; $BOLD = "$E[1m"; $NC = "$E[0m"\
\
function Log-Step($msg) \{\
    Write-Host " $\{GRAY\}[\'95]$\{NC\} $msg"\
    Start-Sleep -Milliseconds 400\
\}\
\
# --- BA\uc0\u350 LANGI\'c7 ---\
Clear-Host\
Write-Host "$\{CYAN\}==================================================$\{NC\}"\
Write-Host "$\{WHITE\}$\{BOLD\}    $L_TITLE$\{NC\}"\
Write-Host "$\{CYAN\}==================================================$\{NC\}"\
Write-Host ""\
\
Log-Step "$L_STEP_CTRL"\
\
# MySQL Kontrol\'fc\
$MYSQL_EXE = Get-Command mysql.exe -ErrorAction SilentlyContinue\
$DUMP_EXE = Get-Command mysqldump.exe -ErrorAction SilentlyContinue\
\
if (-not $DUMP_EXE) \{\
    Write-Host "$\{RED\}$L_ERROR_NOT_FOUND$\{NC\}"; pause; exit\
\}\
\
# Yedekleme Klas\'f6r\'fc\
$DATE_STR = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"\
$BACKUP_DIR = [System.IO.Path]::Combine($env:USERPROFILE, "Documents", "MySQLBackup")\
if (-not (Test-Path $BACKUP_DIR)) \{ New-Item -Path $BACKUP_DIR -ItemType Directory | Out-Null \}\
\
# --- \uc0\u350 \u304 FRE VE BA\u286 LANTI ---\
while ($true) \{\
    Write-Host -NoNewline "$L_PWD_PROMPT $\{GRAY\}$L_PWD_HIDDEN$\{NC\}: "\
    $MYSQL_PWD = Read-Host -AsSecureString\
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MYSQL_PWD)\
    $PLAIN_PWD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)\
\
    $test = echo "SELECT 1;" | & mysql.exe -u root "--password=$PLAIN_PWD" 2>$null\
    if ($LASTEXITCODE -eq 0) \{\
        $SYS_HOSTNAME = hostname\
        Write-Host "$\{GREEN\}$L_CONN_OK$\{NC\}"\
        Write-Host "$L_CONN_INFO $\{CYAN\}localhost$\{NC\} ($SYS_HOSTNAME)"\
        Write-Host "$\{GRAY\}--------------------------------------------------$\{NC\}"\
        break\
    \} else \{\
        Write-Host "$\{RED\} \uc0\u10060  Password incorrect! / \u350 ifre yanl\u305 \u351 !$\{NC\}"\
    \}\
\}\
\
# Veritabanlar\uc0\u305 n\u305  listele\
$SCHEMAS_RAW = echo "SHOW DATABASES;" | & mysql.exe -u root "--password=$PLAIN_PWD" -sN\
$SCHEMAS = $SCHEMAS_RAW | Where-Object \{ $_ -notmatch "information_schema|performance_schema|mysql|sys" \}\
\
# --- SE\'c7\uc0\u304 M EKRANI ---\
Write-Host "`n$\{BOLD\}$L_SELECT_DB$\{NC\}"\
Write-Host " $\{ORANGE\}0)$\{NC\} $\{BOLD\}$L_FULL_BACKUP$\{NC\}"\
\
$schema_list = @()\
$i = 1\
foreach ($db in $SCHEMAS) \{\
    Write-Host " $\{CYAN\}$i)$\{NC\} $db"\
    $schema_list += $db\
    $i++\
\}\
$MAX_CHOICE = $i - 1\
\
while ($true) \{\
    $CHOICE = Read-Host "`n $L_CHOICE (0-$MAX_CHOICE)"\
    if ($CHOICE -eq "0") \{\
        $TARGET = "--all-databases"\
        $FILE_NAME = "$SYS_HOSTNAME-localhost-FULL_BACKUP-$DATE_STR"\
        break\
    \} elseif ($CHOICE -match "^\\d+$" -and $CHOICE -ge 1 -and $CHOICE -le $MAX_CHOICE) \{\
        $SELECTED_DB = $schema_list[$CHOICE-1]\
        $TARGET = "--databases $SELECTED_DB"\
        $FILE_NAME = "$SYS_HOSTNAME-localhost-DB_$SELECTED_DB-$DATE_STR"\
        break\
    \} else \{\
        Write-Host "$\{RED\} \uc0\u9888 \u65039  Invalid / Ge\'e7ersiz!$\{NC\}"\
    \}\
\}\
\
# --- SIKI\uc0\u350 TIRMA ---\
Write-Host "`n$L_COMPRESS_PROMPT"\
$COMPRESS_CHOICE = Read-Host "$L_COMPRESS_ASK"\
\
# --- YEDEKLEME ---\
$DB_FILE = Join-Path $BACKUP_DIR "$FILE_NAME.sql"\
Write-Host ""\
Log-Step "$L_STEP_START"\
\
& mysqldump.exe -u root "--password=$PLAIN_PWD" $TARGET --routines --events --single-transaction --set-gtid-purged=OFF --result-file="$DB_FILE" 2>$null\
\
if ($LASTEXITCODE -eq 0) \{\
    $FINAL_NAME = Split-Path $DB_FILE -Leaf\
\
    if ($COMPRESS_CHOICE -match "^[eEyY]$") \{\
        Log-Step "$L_STEP_ZIP"\
        $ZIP_FILE = Join-Path $BACKUP_DIR "$FILE_NAME.zip"\
        Compress-Archive -Path $DB_FILE -DestinationPath $ZIP_FILE -Force\
        Remove-Item $DB_FILE\
        $FINAL_NAME = Split-Path $ZIP_FILE -Leaf\
    \}\
\
    # --- F\uc0\u304 NAL PANEL\u304  ---\
    Write-Host "`n$\{GREEN\}==================================================$\{NC\}"\
    Write-Host "$\{BOLD\}        $L_SUCCESS$\{NC\}"\
    Write-Host "$\{GREEN\}==================================================$\{NC\}"\
    Write-Host " $L_SAVE_DIR $\{WHITE\}$\{BACKUP_DIR\}$\{NC\}"\
    Write-Host " $L_FILE_NAME"\
    Write-Host "    $\{ORANGE\}$\{BOLD\}$\{FINAL_NAME\}$\{NC\}"\
    Write-Host "$\{GREEN\}==================================================$\{NC\}"\
    explorer.exe $BACKUP_DIR\
\} else \{\
    Write-Host "`n$\{RED\}$L_ERROR_FAIL$\{NC\}"\
\}\
\
# --- \uc0\u304 MZA VE \u304 LET\u304 \u350 \u304 M ---\
Write-Host "`n$\{CYAN\}==================================================$\{NC\}"\
Write-Host "  $\{GRAY\}$L_DEV $\{BOLD_WHITE\}Muharrem AKTAS$\{NC\}"\
Write-Host "  $\{GRAY\}Github:   $\{WHITE\}https://github.com/muroshow/$\{NC\}"\
Write-Host "  $\{GRAY\}LinkedIn: $\{LINKEDIN_BLUE\}https://www.linkedin.com/in/muharremaktas/$\{NC\}"\
Write-Host "$\{CYAN\}==================================================$\{NC\}"\
Read-Host "$L_EXIT"}