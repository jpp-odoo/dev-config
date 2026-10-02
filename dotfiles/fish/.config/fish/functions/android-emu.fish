function android-emu --description 'Launch an Android emulator (default: first AVD)'
    set -l emu ~/Android/Sdk/emulator/emulator
    set -q ANDROID_AVD_HOME; or set -lx ANDROID_AVD_HOME ~/.config/.android/avd
    set -l avd $argv[1]
    if test -z "$avd"
        set avd ($emu -list-avds 2>/dev/null)[1]
    end
    if test -z "$avd"
        echo "No AVD found. Create one in Android Studio > Device Manager." >&2
        return 1
    end
    echo "Starting $avd (goo worktrees at http://<name>.localhost)"
    setsid -f $emu -avd $avd $argv[2..] >/dev/null 2>&1
    # Once booted: Chrome resolves *.localhost to the host (10.0.2.2), plus port 8080 forwarded for apps
    setsid -f bash -c '
      adb=$HOME/Android/Sdk/platform-tools/adb
      $adb wait-for-device
      $adb shell "echo \"_ --host-resolver-rules=\\\\\"MAP *.localhost 10.0.2.2\\\\\"\" > /data/local/tmp/chrome-command-line"
      $adb shell am set-debug-app --persistent com.android.chrome
      $adb reverse tcp:8080 tcp:80
    ' >/dev/null 2>&1
end
