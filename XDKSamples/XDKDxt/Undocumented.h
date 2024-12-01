#pragma once

#include <xtl.h>

typedef VOID(*PKSTART_ROUTINE) (IN PVOID StartContext);
typedef VOID(*PKSYSTEM_ROUTINE) (IN PKSTART_ROUTINE StartRoutine OPTIONAL, IN PVOID StartContext OPTIONAL);

extern "C"
{
    DWORD NTAPI
        PsCreateSystemThreadEx(
            OUT PHANDLE ThreadHandle,
            IN SIZE_T ThreadExtensionSize,
            IN SIZE_T KernelStackSize,
            IN SIZE_T TlsDataSize,
            OUT PHANDLE ThreadId OPTIONAL,
            IN PKSTART_ROUTINE StartRoutine,
            IN PVOID StartContext,
            IN BOOLEAN CreateSuspended,
            IN BOOLEAN DebuggerThread,
            IN PKSYSTEM_ROUTINE SystemRoutine OPTIONAL
        );
}