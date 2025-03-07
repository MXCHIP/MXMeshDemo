void OpenApiClient_SetCallbacks(
    void (*onConnected)(void *client),
    void (*onDisconnected)(void *client),
    void (*onData)(void *client, const char *message),
    void (*onConnectError)(void *client, int err));
void *OpenApiClient_New();
void OpenApiClient_Connect(void *clientPtr, const char *ipAddr, const char *password);
void OpenApiClient_Send(void *clientPtr, const char *message);
void OpenApiClient_Disconnect(void *clientPtr);
void OpenApiClient_Cleanup(void *clientPtr);
