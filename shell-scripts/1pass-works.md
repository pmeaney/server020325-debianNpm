```bash
VAULT="Z_Tech_ClicksAndCodes"
ITEM_TITLE="2025 Feb 020325 Debian project"

echo "1pass does not yet allow uploading of files from CLI. Will upload pub keys only."

# Check if the item exists in the vault

if op item get "$ITEM_TITLE" --vault "$VAULT" &>/dev/null; then
echo "Item '$ITEM_TITLE' exists in vault '$VAULT'. Public keys will be updated."

    # Update existing item with just the public keys
    op item edit "$ITEM_TITLE" --vault "$VAULT" \
        "cicd_bot_key[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub)" \
        "human_dev_key[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub)"

else
echo "Item '$ITEM_TITLE' does not exist in vault '$VAULT'. Creating new item with public keys."

    # Create new item with just the public keys
    op item create --vault "$VAULT" \
        --title "$ITEM_TITLE" \
        "cicd_bot_key[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub)" \
        "human_dev_key[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub)"

fi
```
