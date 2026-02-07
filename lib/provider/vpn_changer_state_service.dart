import 'package:flutter/foundation.dart'; // ایمپورت شد

enum VpnState {
  v2rayState,
  wireGuardState,
}


final ValueNotifier<VpnState> vpnStateNotifier =
ValueNotifier<VpnState>(VpnState.v2rayState);