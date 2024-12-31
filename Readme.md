---

# **SoftEther VPN Server Docker 部署使用說明**

## **介紹**

這個 Docker Compose 配置檔允許您快速部署 SoftEther VPN Server 容器化應用程式。該服務使用 Aron666 (我) 提供的 SoftEther VPN Server 映像，支持高效能 VPN 伺服器部署。

---

## **配置檔內容**

```
yaml複製程式碼version: '3'
services:
  vpnserver:
    image: aron666/softether-vpnserver
    environment:
      VPN_SERVER_PASSWORD: "password"
    volumes:
      - ./vpnserver:/app 
      - /dev:/dev
      - /lib/modules:/lib/modules
    privileged: true
    network_mode: "host"
    cap_add:
      - ALL
    stdin_open: true
    tty: true
    restart: always
```

---

## **參數說明**

### **1.** `services.vpnserver`

- **image**:
  - 指定使用的 Docker 映像。
  - 此處為 `aron666/softether-vpnserver`，由 Aron 提供的 SoftEther VPN Server 映像。
- **environment**:
  - `VPN_SERVER_PASSWORD`:
    - 設定 SoftEther VPN Server 管理密碼。
    - 預設為 `"password"`，建議部署前更改為安全密碼。

### **2.** `volumes`

用於掛載目錄，確保數據持久化和系統相容性：

- `./vpnserver:/app`:
  - 將當前目錄下的 `vpnserver` 文件夾掛載到容器內的 `/app`。
  - **用途**: 儲存 VPN Server 配置和數據。
- `/dev:/dev`:
  - 掛載宿主機的 `/dev` 目錄，提供對設備的存取。
- `/lib/modules:/lib/modules`:
  - 掛載宿主機的 Linux 核心模組，確保容器能正確操作網路相關功能。

### **3.** `privileged`

- 設置為 `true`，允許容器以特權模式運行，提供更高的權限（例如訪問核心網路功能）。

### **4.** `network_mode`

- 設置為 `"host"`，容器將與宿主機共用網絡棧，允許直接使用宿主機的 IP。

### **5.** `cap_add`

- 增加容器能力，使用 `ALL` 授予容器所有 Linux 能力。

### **6.** `stdin_open` **和** `tty`

- `stdin_open: true` 和 `tty: true`:
  - 確保容器啟動後，保持終端會話打開，方便進行調試或互動操作。

### **7.** `restart`

- `always`:
  - 當容器意外停止時，自動重新啟動。

---

## **部署步驟**

### **1. 環境準備**

確保已安裝以下工具：

- Docker
- Docker Compose

### **2. 編輯配置檔**

- 將上述配置檔儲存為 `docker compose.yml`。
- 修改以下參數：
  - `VPN_SERVER_PASSWORD`: 設定強密碼。
  - 確保掛載路徑（`./vpnserver`）存在，並可用於保存 VPN 設定。

### **3. 啟動服務**

執行以下指令：

```
docker compose up -d
```

- `-d`: 以後台模式啟動。

### **4. 驗證服務**

啟動完成後，可通過 SoftEther VPN 管理工具或命令行客戶端連接至伺服器進行配置。

---

## **容器管理指令**

- 查看日誌：

  ```
  docker compose logs vpnserver
  ```
- 停止服務：

  ```
  docker compose down
  ```
- 重啟服務：

  ```
  docker compose restart vpnserver
  ```

---

## **注意事項**

1. **密碼安全性**: 請勿將弱密碼用於 `VPN_SERVER_PASSWORD`，以免造成安全風險。
2. **宿主機網路要求**: 使用 `network_mode: host` 時，確保宿主機的網絡端口未被佔用。
3. **文件目錄權限**: 確保宿主機的目錄（如 `vpnserver`）有足夠的讀寫權限。