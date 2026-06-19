import Foundation
import UserNotifications

struct ReminderSyncResult: Hashable {
  let status: ReminderPermissionStatus
  let message: String
}

struct ReminderNotificationScheduler {
  private let center = UNUserNotificationCenter.current()
  private let requestIdentifier = "daily-word-reminder"

  func currentStatus() async -> ReminderPermissionStatus {
    let settings = await center.notificationSettings()
    return ReminderPermissionStatus(settings.authorizationStatus)
  }

  func sync(enabled: Bool, hour: Int) async -> ReminderSyncResult {
    center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])

    guard enabled else {
      let status = await currentStatus()
      return ReminderSyncResult(status: status, message: "Daily reminder is off.")
    }

    let status = await authorizationStatusForEnabledReminder()
    guard status.canSchedule else {
      return ReminderSyncResult(status: status, message: "Notifications need permission before reminders can be scheduled.")
    }

    let content = UNMutableNotificationContent()
    content.title = "Daily words are ready"
    content.body = "Play today's set before the group leaderboard gets away from you."
    content.sound = .default

    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)

    do {
      try await center.add(request)
      return ReminderSyncResult(status: status, message: "Daily reminder scheduled for \(hour):00.")
    } catch {
      return ReminderSyncResult(status: status, message: "Could not schedule the reminder.")
    }
  }

  private func authorizationStatusForEnabledReminder() async -> ReminderPermissionStatus {
    let current = await currentStatus()
    if current != .notDetermined {
      return current
    }

    do {
      let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
      return granted ? .authorized : .denied
    } catch {
      return .denied
    }
  }
}

private extension ReminderPermissionStatus {
  init(_ status: UNAuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    case .provisional:
      self = .provisional
    case .ephemeral:
      self = .ephemeral
    @unknown default:
      self = .unknown
    }
  }

  var canSchedule: Bool {
    switch self {
    case .authorized, .provisional, .ephemeral:
      true
    case .unknown, .notDetermined, .denied:
      false
    }
  }
}
