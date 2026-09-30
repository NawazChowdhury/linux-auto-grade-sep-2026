#!/bin/bash
# ==============================================================================
# Auto-Grading Script for Guided Lab: Linux Files, Users, Permissions & Automation
# Total Marks: 50 | Run as root: sudo bash grade_lab.sh
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (sudo)."
  exit 1
fi

SCORE_A1=0
SCORE_A2=0
SCORE_A3=0
SCORE_A4=0
SCORE_A5=0

echo "========================================================================"
echo "          AUTOMATED LAB EVALUATION REPORT & GRADE SUMMARY              "
echo "========================================================================"
echo

# ------------------------------------------------------------------------------
# ACTIVITY 1: Files and Folders (10 Marks)
# ------------------------------------------------------------------------------
echo "[ Activity 1: Files and Folders ]"

# 1. Directory Structure (4 Marks)
DIRS_REQ=(
    "/opt/company"
    "/opt/company/documents"
    "/opt/company/documents/reports"
    "/opt/company/documents/invoices"
    "/opt/company/projects"
    "/opt/company/projects/projectA"
    "/opt/company/projects/projectB"
    "/opt/company/backup"
)
A1_DIRS_OK=true
for d in "${DIRS_REQ[@]}"; do
    if [ ! -d "$d" ]; then
        A1_DIRS_OK=false
        break
    fi
done

if [ "$A1_DIRS_OK" = true ]; then
    ((SCORE_A1 += 4))
    echo "  [✓] Directory structure complete (+4)"
else
    echo "  [✗] Directory structure incomplete (+0)"
fi

# 2. Files Creation (2 Marks) - Check file existence
FILES_A1=(
    "/opt/company/documents/reports/report1.txt"
    "/opt/company/documents/reports/report2.txt"
    "/opt/company/documents/invoices/invoice1.txt"
    "/opt/company/documents/invoices/invoice2.txt"
)
A1_FILES_OK=true
for f in "${FILES_A1[@]}"; do
    if [ ! -f "$f" ]; then
        # Search if placed anywhere in /opt/company if exact path missing
        FOUND_F=$(find /opt/company -type f -name "$(basename "$f")" 2>/dev/null)
        if [ -z "$FOUND_F" ]; then
            A1_FILES_OK=false
            break
        fi
    fi
done

if [ "$A1_FILES_OK" = true ]; then
    ((SCORE_A1 += 2))
    echo "  [✓] Required txt files created (+2)"
else
    echo "  [✗] Required txt files missing (+0)"
fi

# 3. Non-empty files (2 Marks)
A1_TEXT_OK=true
for f in "${FILES_A1[@]}"; do
    ACTUAL_F=$(find /opt/company -type f -name "$(basename "$f")" 2>/dev/null | head -n 1)
    if [ -z "$ACTUAL_F" ] || [ ! -s "$ACTUAL_F" ]; then
        A1_TEXT_OK=false
        break
    fi
done

if [ "$A1_FILES_OK" = true ] && [ "$A1_TEXT_OK" = true ]; then
    ((SCORE_A1 += 2))
    echo "  [✓] Files contain text (+2)"
else
    echo "  [✗] Files are empty or missing (+0)"
fi

# 4. Display structure check (2 Marks) - Always awarded if tree/find target exists
if [ -d "/opt/company" ]; then
    ((SCORE_A1 += 2))
    echo "  [✓] Directory structure discoverable (+2)"
fi

echo "  Activity 1 Subtotal: $SCORE_A1 / 10"
echo

# ------------------------------------------------------------------------------
# ACTIVITY 2: Users and Groups (10 Marks)
# ------------------------------------------------------------------------------
echo "[ Activity 2: Users and Groups ]"

# 1. User alice (2 Marks)
if id "alice" &>/dev/null; then
    ((SCORE_A2 += 2))
    echo "  [✓] User 'alice' exists (+2)"
else
    echo "  [✗] User 'alice' not found (+0)"
fi

# 2. User bob (2 Marks)
if id "bob" &>/dev/null; then
    ((SCORE_A2 += 2))
    echo "  [✓] User 'bob' exists (+2)"
else
    echo "  [✗] User 'bob' not found (+0)"
fi

# 3. Group projectteam (2 Marks)
if getent group "projectteam" &>/dev/null; then
    ((SCORE_A2 += 2))
    echo "  [✓] Group 'projectteam' exists (+2)"
else
    echo "  [✗] Group 'projectteam' not found (+0)"
fi

# 4. Add users to group (2 Marks)
ALICE_IN_GRP=$(id -nG "alice" 2>/dev/null | grep -qw "projectteam" && echo "yes" || echo "no")
BOB_IN_GRP=$(id -nG "bob" 2>/dev/null | grep -qw "projectteam" && echo "yes" || echo "no")

if [ "$ALICE_IN_GRP" = "yes" ] && [ "$BOB_IN_GRP" = "yes" ]; then
    ((SCORE_A2 += 2))
    echo "  [✓] Both users added to 'projectteam' (+2)"
else
    echo "  [✗] Users missing from group 'projectteam' (+0)"
fi

# 5. Directory /opt/company/projects/shared with group projectteam (2 Marks)
SHARED_DIR="/opt/company/projects/shared"
if [ -d "$SHARED_DIR" ]; then
    DIR_GRP=$(stat -c '%G' "$SHARED_DIR" 2>/dev/null)
    if [ "$DIR_GRP" = "projectteam" ]; then
        ((SCORE_A2 += 2))
        echo "  [✓] Shared dir exists & owned by 'projectteam' (+2)"
    else
        echo "  [✗] Shared dir group ownership is '$DIR_GRP' (Expected: projectteam) (+0)"
    fi
else
    echo "  [✗] Directory '$SHARED_DIR' does not exist (+0)"
fi

echo "  Activity 2 Subtotal: $SCORE_A2 / 10"
echo

# ------------------------------------------------------------------------------
# ACTIVITY 3: File and Directory Permissions (10 Marks)
# ------------------------------------------------------------------------------
echo "[ Activity 3: File and Directory Permissions ]"

# 1. Group ownership of /opt/company/projects/shared (2 Marks)
if [ -d "$SHARED_DIR" ] && [ "$(stat -c '%G' "$SHARED_DIR")" = "projectteam" ]; then
    ((SCORE_A3 += 2))
    echo "  [✓] Directory group owner is 'projectteam' (+2)"
else
    echo "  [✗] Directory group owner incorrect (+0)"
fi

# 2. Directory permissions 770 (3 Marks)
if [ -d "$SHARED_DIR" ]; then
    PERM_DIR=$(stat -c '%a' "$SHARED_DIR")
    if [ "$PERM_DIR" = "770" ]; then
        ((SCORE_A3 += 3))
        echo "  [✓] Directory permissions are 770 (+3)"
    else
        echo "  [✗] Directory permissions are $PERM_DIR (Expected: 770) (+0)"
    fi
else
    echo "  [✗] Directory missing (+0)"
fi

# 3. Create shared_notes.txt (1 Mark)
NOTES_FILE="$SHARED_DIR/shared_notes.txt"
if [ -f "$NOTES_FILE" ]; then
    ((SCORE_A3 += 1))
    echo "  [✓] File 'shared_notes.txt' exists (+1)"
    
    # 4. Group ownership of shared_notes.txt (2 Marks)
    if [ "$(stat -c '%G' "$NOTES_FILE")" = "projectteam" ]; then
        ((SCORE_A3 += 2))
        echo "  [✓] File group owner is 'projectteam' (+2)"
    else
        echo "  [✗] File group owner is '$(stat -c '%G' "$NOTES_FILE")' (+0)"
    fi

    # 5. File permissions 660 (1 Mark)
    PERM_FILE=$(stat -c '%a' "$NOTES_FILE")
    if [ "$PERM_FILE" = "660" ]; then
        ((SCORE_A3 += 1))
        echo "  [✓] File permissions are 660 (+1)"
    else
        echo "  [✗] File permissions are $PERM_FILE (Expected: 660) (+0)"
    fi
else
    echo "  [✗] File 'shared_notes.txt' missing (+0)"
fi

# 6. Verification check (1 Mark)
if [ "$SCORE_A3" -ge 8 ]; then
    ((SCORE_A3 += 1))
    echo "  [✓] Permission verification check passed (+1)"
fi

echo "  Activity 3 Subtotal: $SCORE_A3 / 10"
echo

# ------------------------------------------------------------------------------
# ACTIVITY 4: Create a Backup Script (10 Marks)
# ------------------------------------------------------------------------------
echo "[ Activity 4: Create a Backup Script ]"

SCRIPT_PATH="/usr/local/bin/company_backup.sh"

# 1. Correct script location (2 Marks)
if [ -f "$SCRIPT_PATH" ]; then
    ((SCORE_A4 += 2))
    echo "  [✓] Script exists at /usr/local/bin/company_backup.sh (+2)"
else
    echo "  [✗] Script missing at /usr/local/bin/company_backup.sh (+0)"
fi

# 2. Executable permission (1 Mark)
if [ -x "$SCRIPT_PATH" ]; then
    ((SCORE_A4 += 1))
    echo "  [✓] Script is executable (+1)"
else
    echo "  [✗] Script is not executable (+0)"
fi

if [ -f "$SCRIPT_PATH" ]; then
    # 3. Inspect source/destination and date directory variables in script (4 Marks)
    HAS_SOURCE=$(grep -i 'SOURCE=.*company/documents' "$SCRIPT_PATH" || grep -i '/opt/company/documents' "$SCRIPT_PATH")
    HAS_DEST=$(grep -i 'BACKUP=.*company/backup' "$SCRIPT_PATH" || grep -i '/opt/company/backup' "$SCRIPT_PATH")
    HAS_DATE=$(grep -i 'date' "$SCRIPT_PATH")

    if [ -n "$HAS_SOURCE" ] && [ -n "$HAS_DEST" ]; then
        ((SCORE_A4 += 2))
        echo "  [✓] Correct source/destination references (+2)"
    else
        echo "  [✗] Source or destination paths missing/incorrect in script (+0)"
    fi

    if [ -n "$HAS_DATE" ]; then
        ((SCORE_A4 += 2))
        echo "  [✓] Date-based backup directory logic present (+2)"
    else
        echo "  [✗] Dynamic date variable missing in script (+0)"
    fi

    # 4. Dry-run test execution for BACKUP SUCCESS & file creation (3 Marks)
    # Execute script and capture output
    SCRIPT_OUT=$("$SCRIPT_PATH" 2>&1)
    if echo "$SCRIPT_OUT" | grep -q "BACKUP SUCCESS"; then
        ((SCORE_A4 += 1))
        echo "  [✓] Script returned 'BACKUP SUCCESS' (+1)"
    fi

    # Check if backup directory created and contains files
    TODAY_DATE=$(date +%Y-%m-%d)
    BACKUP_DIR="/opt/company/backup/backup-$TODAY_DATE"
    if [ -d "$BACKUP_DIR" ] && [ $(find "$BACKUP_DIR" -type f | wc -l) -gt 0 ]; then
        ((SCORE_A4 += 2))
        echo "  [✓] Backup directory created and contains files (+2)"
    else
        echo "  [✗] Backup execution failed or created no files (+0)"
    fi
fi

echo "  Activity 4 Subtotal: $SCORE_A4 / 10"
echo

# ------------------------------------------------------------------------------
# ACTIVITY 5: Automated Daily Backup (10 Marks)
# ------------------------------------------------------------------------------
echo "[ Activity 5: Automated Daily Backup ]"

ROOT_CRON=$(crontab -l 2>/dev/null)
CRON_LINE=$(echo "$ROOT_CRON" | grep "company_backup.sh")

if [ -n "$CRON_LINE" ]; then
    # 1. Cron job existing (2 Marks)
    ((SCORE_A5 += 2))
    echo "  [✓] Root cron job found (+2)"

    # 2. Cron schedule syntax (Every day format) (3 Marks)
    # Check if standard 5-part cron syntax with daily setting (* * *)
    if echo "$CRON_LINE" | grep -qE '^[0-9]+[[:space:]]+[0-9]+[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*'; then
        ((SCORE_A5 += 3))
        echo "  [✓] Cron correctly configured with daily execution (+3)"
    else
        ((SCORE_A5 += 1))
        echo "  [~] Cron entry present, but timing schedule may vary (+1)"
    fi

    # 3. Log file redirection /var/log/company_backup.log (2 Marks)
    if echo "$CRON_LINE" | grep -q "/var/log/company_backup.log"; then
        ((SCORE_A5 += 2))
        echo "  [✓] Output redirected to /var/log/company_backup.log (+2)"
    else
        echo "  [✗] Log file redirection missing (+0)"
    fi
else
    echo "  [✗] No root cron job configured for company_backup.sh (+0)"
fi

# 4. Check log file execution status (2 Marks)
LOG_FILE="/var/log/company_backup.log"
if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
    ((SCORE_A5 += 2))
    echo "  [✓] Log file exists and is populated (+2)"
else
    echo "  [✗] Log file /var/log/company_backup.log is missing or empty (+0)"
fi

# 5. Verification check (1 Mark)
if [ "$SCORE_A5" -ge 7 ]; then
    ((SCORE_A5 += 1))
    echo "  [✓] Automation verification passed (+1)"
fi

echo "  Activity 5 Subtotal: $SCORE_A5 / 10"
echo

# ------------------------------------------------------------------------------
# FINAL REPORT
# ------------------------------------------------------------------------------
TOTAL_SCORE=$((SCORE_A1 + SCORE_A2 + SCORE_A3 + SCORE_A4 + SCORE_A5))

echo "========================================================================"
echo "                         FINAL GRADE TABLE                              "
echo "========================================================================"
printf "%-25s | %-12s | %-10s\n" "Activity" "Difficulty" "Score"
echo "------------------------------------------------------------------------"
printf "%-25s | %-12s | %-10s\n" "1. Files & Folders" "Easy" "$SCORE_A1 / 10"
printf "%-25s | %-12s | %-10s\n" "2. Users & Groups" "Easy" "$SCORE_A2 / 10"
printf "%-25s | %-12s | %-10s\n" "3. Permissions" "Medium" "$SCORE_A3 / 10"
printf "%-25s | %-12s | %-10s\n" "4. Backup Script" "Medium" "$SCORE_A4 / 10"
printf "%-25s | %-12s | %-10s\n" "5. Cron Automation" "Hard" "$SCORE_A5 / 10"
echo "------------------------------------------------------------------------"
printf "%-25s | %-12s | %-10s\n" "TOTAL" "Mixed" "$TOTAL_SCORE / 50"
echo "========================================================================"

PERCENTAGE=$((TOTAL_SCORE * 100 / 50))
echo "FINAL SCORE: $TOTAL_SCORE / 50 ($PERCENTAGE%)"
echo