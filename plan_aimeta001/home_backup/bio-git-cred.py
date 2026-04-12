def run_termux_fingerprint():
    """Trigger biometric prompt with custom text and longer timeout"""
    try:
        result = subprocess.run(
            [
                "termux-fingerprint",
                "-t", "GitHub Push Required",
                "-s", "Touch the fingerprint sensor",
                "-d", "Authenticate to access GitHub credentials"
            ],
            capture_output=True,
            text=True,
            timeout=60  # 60 seconds to scan
        )
        output = result.stdout.strip()
        if result.returncode == 0 and "AUTH_RESULT_SUCCESS" in output:
            return True
        else:
            print(f"Auth failed or cancelled: {output}", file=sys.stderr)
            return False
    except subprocess.TimeoutExpired:
        print("Biometric prompt timed out – please try again", file=sys.stderr)
        return False
    except FileNotFoundError:
        print("termux-fingerprint not available – install Termux:API app from F-Droid", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Termux:API error (try restarting Termux): {e}", file=sys.stderr)
        return False
