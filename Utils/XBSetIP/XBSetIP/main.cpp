#include <iostream>
#include <regex>
#include <windows.h>
#include <string>

bool SetRegistryValue(HKEY hKeyRoot, const std::string& subKey, const std::string& valueName, const std::string& valueData) 
{
    HKEY hKey;
    LONG result = RegCreateKeyExA(hKeyRoot, subKey.c_str(), 0, NULL, 0, KEY_WRITE, NULL, &hKey, NULL);
    if (result != ERROR_SUCCESS) {
        std::cerr << "Error opening/creating key: " << result << std::endl;
        return false;
    }

    result = RegSetValueExA(hKey, valueName.c_str(), 0, REG_SZ, (const BYTE*)valueData.c_str(), valueData.size() + 1);
    RegCloseKey(hKey);

    if (result != ERROR_SUCCESS) {
        std::cerr << "Error setting value: " << result << std::endl;
        return false;
    }

    return true;
}

void DisplayUsage() {
    std::cout << "Usage: xbsetip.exe [IP_ADDRESS|HOSTNAME]" << std::endl;
    std::cout << "  IP_ADDRESS | HOSTNAME : Specify the Xbox IP address or hostname." << std::endl;
    std::cout << "  help                  : Display this usage information." << std::endl;
}

int main(int argc, char* argv[]) 
{
    std::string address;

    if (argc > 1) 
    {
        if (std::string(argv[1]) == "-help" || std::string(argv[1]) == "-?") 
        {
            DisplayUsage();
            return 0;
        }

        address = argv[1];
    }
    else 
    {
        std::cout << "Enter your Xbox IP address or hostname: ";
        std::getline(std::cin, address);
    }

    if (SetRegistryValue(HKEY_CURRENT_USER, "Software\\Microsoft\\XboxSDK", "XboxName", address))
    {
        std::cout << std::endl << "Successfully set Xbox address to: " << address << std::endl;
    }
    else 
    {
        std::cerr << std::endl << "Failed." << std::endl;
    }

    return 0;
}
