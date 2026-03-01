#!/bin/bash

# --- DİL VE METİN AYARLARI ---
if [[ "$LANG" == tr* ]]; then
    L_TITLE="MacOS MySQL AKILLI YEDEKLEME SİHİRBAZI 🧙‍♂️"
    L_STEP_CTRL="Sistem kontrolleri yapılıyor..."
    L_ERROR_NOT_FOUND="❌ HATA: MySQL bulunamadı!"
    L_PWD_PROMPT=" root şifresini girin"
    L_PWD_HIDDEN="(Gizli)"
    L_CONN_OK=" ✅ Bağlantı başarılı!"
    L_CONN_INFO=" 🌐 Dinamik Bağlantı:"
    L_SELECT_DB="Yedeklenecek Veritabanını Seçin:"
    L_FULL_BACKUP="HEPSİNİ YEDEKLE"
    L_CHOICE="Seçiminiz"
    L_COMPRESS_PROMPT="📦 Sıkıştırma Seçeneği"
    L_COMPRESS_ASK=" Yedek dosyası ZIP olarak sıkıştırılsın mı? (e/h): "
    L_STEP_START="Yedekleme işlemi başlatıldı..."
    L_STEP_ZIP="Dosyalar sıkıştırılıyor..."
    L_SUCCESS="🚀 İŞLEM BAŞARIYLA TAMAMLANDI!"
    L_SAVE_DIR="📍 Kayıt Dizini:"
    L_FILE_NAME="💾 Yedek dosyanız şu isimle oluşturulmuştur:"
    L_ERROR_FAIL="❌ HATA: Yedekleme başarısız!"
    L_EXIT="Kapatmak için Enter'a basın..."
    L_DEV="Geliştirici:"
else
    L_TITLE="MacOS MySQL SMART BACKUP WIZARD 🧙‍♂️"
    L_STEP_CTRL="Running system checks..."
    L_ERROR_NOT_FOUND="❌ ERROR: MySQL not found!"
    L_PWD_PROMPT=" Enter root password"
    L_PWD_HIDDEN="(Hidden)"
    L_CONN_OK=" ✅ Connection successful!"
    L_CONN_INFO=" 🌐 Dynamic Connection:"
    L_SELECT_DB="Select Database to Backup:"
    L_FULL_BACKUP="BACKUP ALL"
    L_CHOICE="Your Choice"
    L_COMPRESS_PROMPT="📦 Compression Option"
    L_COMPRESS_ASK=" Compress backup as ZIP? (y/n): "
    L_STEP_START="Backup process started..."
    L_STEP_ZIP="Compressing files..."
    L_SUCCESS="🚀 PROCESS COMPLETED SUCCESSFULLY!"
    L_SAVE_DIR="📍 Save Directory:"
    L_FILE_NAME="💾 Your backup file has been created as:"
    L_ERROR_FAIL="❌ ERROR: Backup failed!"
    L_EXIT="Press Enter to close..."
    L_DEV="Developer:"
fi

# --- RENKLER ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD_WHITE='\033[1;97m'
GRAY='\033[0;90m'
ORANGE='\033[0;33m'
LINKEDIN_BLUE='\033[1;34m'
BOLD='\033[1m'
NC='\033[0m'

log_step() {
    echo -e " ${GRAY}[•]${NC} $1"
    sleep 0.4
}

# --- BAŞLANGIÇ ---
clear
echo -e "${CYAN}==================================================${NC}"
echo -e "${WHITE}${BOLD}    $L_TITLE${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# MySQL Path Ayarları
MYSQL_PATHS=("/usr/local/mysql/bin" "/usr/local/bin" "/opt/homebrew/bin" "/opt/homebrew/opt/mysql/bin")
for path in "${MYSQL_PATHS[@]}"; do [ -d "$path" ] && export PATH="$path:$PATH"; done

log_step "$L_STEP_CTRL"

if ! command -v mysql &> /dev/null; then
    echo -e "${RED}$L_ERROR_NOT_FOUND${NC}"; exit 1
fi

# Yedekleme Klasörü
DATE_STR=$(date +"%Y-%m-%d-%H-%M-%S")
BACKUP_DIR=~/Documents/MySQLBackup
mkdir -p "$BACKUP_DIR"

# --- ŞİFRE VE BAĞLANTI ---
while true; do
    echo -n -e "$L_PWD_PROMPT ${GRAY}$L_PWD_HIDDEN${NC}: "
    read -s MYSQL_PWD
    export MYSQL_PWD
    echo ""
    if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        DB_HOST=$(mysql -u root -sN -e "SELECT SUBSTRING_INDEX(USER(), '@', -1);" 2>/dev/null)
        SYS_HOSTNAME=$(hostname)
        echo -e "${GREEN}$L_CONN_OK${NC}"
        echo -e "$L_CONN_INFO ${CYAN}${DB_HOST}${NC} (${SYS_HOSTNAME})"
        echo -e "${GRAY}--------------------------------------------------${NC}"
        break 
    else
        echo -e "${RED} ❌ Password incorrect! / Şifre yanlış!${NC}"
    fi
done

# Veritabanlarını listele
SCHEMAS=$(mysql -u root -sN -e "SHOW DATABASES" | grep -Ev "(information_schema|performance_schema|mysql|sys)")

# --- SEÇİM EKRANI ---
echo -e "\n${BOLD}$L_SELECT_DB${NC}"
echo -e " ${ORANGE}0)${NC} ${BOLD}$L_FULL_BACKUP${NC}"

i=1
schema_list=()
while read -r line; do
    echo -e " ${CYAN}$i)${NC} $line"
    schema_list[$i]=$line
    ((i++))
done <<< "$SCHEMAS"
MAX_CHOICE=$((i-1))

while true; do
    echo -n -e "\n $L_CHOICE (0-$MAX_CHOICE): "
    read CHOICE
    if [[ "$CHOICE" == "0" ]]; then
        FILE_NAME="${SYS_HOSTNAME}-${DB_HOST}-FULL_BACKUP-${DATE_STR}"
        TARGET="--all-databases"; break
    elif [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$MAX_CHOICE" ]; then
        SELECTED_DB=${schema_list[$CHOICE]}
        FILE_NAME="${SYS_HOSTNAME}-${DB_HOST}-DB_${SELECTED_DB}-${DATE_STR}"
        TARGET="--databases $SELECTED_DB"; break
    else
        echo -e "${RED} ⚠️ Invalid / Geçersiz!${NC}"
    fi
done

# --- SIKIŞTIRMA ---
echo -e "\n$L_COMPRESS_PROMPT"
echo -n -e "$L_COMPRESS_ASK"
read COMPRESS_CHOICE

# --- YEDEKLEME ---
DB_FILE="$BACKUP_DIR/${FILE_NAME}.sql"
USER_FILE="$BACKUP_DIR/${FILE_NAME}-users_grants.sql"

echo ""
log_step "$L_STEP_START"

if mysqldump -u root $TARGET --routines --events --single-transaction --set-gtid-purged=OFF > "$DB_FILE" 2>/dev/null; then
    mysql -u root -BNe "SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user NOT IN ('mysql.session', 'mysql.sys', 'root')" | mysql -u root -BN | sed 's/$/;/' > "$USER_FILE" 2>/dev/null
    
    FINAL_NAME="$(basename "$DB_FILE")"

    if [[ "$COMPRESS_CHOICE" =~ ^[eEyY]$ ]]; then
        log_step "$L_STEP_ZIP"
        ZIP_FILE="$BACKUP_DIR/${FILE_NAME}.zip"
        zip -j "$ZIP_FILE" "$DB_FILE" "$USER_FILE" > /dev/null
        rm -f "$DB_FILE" "$USER_FILE"
        FINAL_NAME="$(basename "$ZIP_FILE")"
    fi

    # --- FİNAL PANELİ ---
    echo ""
    echo -e "${GREEN}==================================================${NC}"
    echo -e "${BOLD}        $L_SUCCESS${NC}"
    echo -e "${GREEN}==================================================${NC}"
    echo -e " $L_SAVE_DIR ${WHITE}${BACKUP_DIR}${NC}"
    echo -e " $L_FILE_NAME"
    echo -e "    ${ORANGE}${BOLD}${FINAL_NAME}${NC}"
    echo -e "${GREEN}==================================================${NC}"
    open "$BACKUP_DIR"
else
    echo -e "\n${RED}$L_ERROR_FAIL${NC}"
    rm -f "$DB_FILE" "$USER_FILE"
fi

# --- İMZA VE İLETİŞİM ---
unset MYSQL_PWD
echo ""
echo -e "${CYAN}==================================================${NC}"
echo -e "  ${GRAY}$L_DEV ${BOLD_WHITE}Muharrem AKTAS${NC}"
echo -e "  ${GRAY}Github:   ${WHITE}https://github.com/muroshow/${NC}"
echo -e "  ${GRAY}LinkedIn: ${LINKEDIN_BLUE}https://www.linkedin.com/in/muharremaktas/${NC}"
echo -e "${CYAN}==================================================${NC}"
read -p "$L_EXIT"