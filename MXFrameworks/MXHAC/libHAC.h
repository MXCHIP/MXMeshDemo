void HAC_Init();
int HAC_Connect(const char *addr, int port, const char *mac, const char *password);
int HAC_Get(const char *path, const char *args);
int HAC_Put(const char *path, const char *body);
int HAC_GetStatus();
const char *HAC_GetBody();
void HAC_Disconnect();
void HAC_SetOnDisconnect(void (*callback)());
void HAC_SetOnEvent(void (*callback)(const char *event));
