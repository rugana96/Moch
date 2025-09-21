import Foundation
import SwiftData

@Model
final class AppConfiguration {
    var notificationsEnabled: Bool
    var defaultLeadTimeInHours: Double
    var use24HourClock: Bool

    init(notificationsEnabled: Bool = true,
         defaultLeadTimeInHours: Double = 24,
         use24HourClock: Bool = false) {
        self.notificationsEnabled = notificationsEnabled
        self.defaultLeadTimeInHours = defaultLeadTimeInHours
        self.use24HourClock = use24HourClock
    }
}
