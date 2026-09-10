// omni-ek - EventKit reader for the omni Calendar provider.
//
//   omni-ek <hours>   TSV: start_epoch  end_epoch  meet_url  HH:mm  title
//                     timed events from now-1h to now+<hours>, sorted by start;
//                     skipped: all-day events, birthday/subscription calendars,
//                     cancelled events, and invitations you declined.
//   omni-ek --status  authorized | denied | notDetermined  (never prompts)
//
// Exit 0 ok, 1 access denied, 2 timed out waiting for the permission dialog.
// Compiled rather than scripted because requesting Calendar access needs a
// completion block, which osascript cannot express. Titles are cleaned of
// control characters and tabs, and cut to 24 characters, so the launcher can
// render them with one awk pass (BSD awk counts bytes, not characters).
import EventKit
import Foundation

let args = CommandLine.arguments
let store = EKEventStore()

func status() -> String {
    switch EKEventStore.authorizationStatus(for: .event) {
    case .fullAccess, .authorized: return "authorized"
    case .denied, .restricted, .writeOnly: return "denied"
    default: return "notDetermined"
    }
}

if args.count > 1 && args[1] == "--status" { print(status()); exit(0) }

let hours = Double(args.count > 1 ? args[1] : "36") ?? 36
let sem = DispatchSemaphore(value: 0)
var granted = false
store.requestFullAccessToEvents { ok, _ in granted = ok; sem.signal() }
if sem.wait(timeout: .now() + 60) == .timedOut { exit(2) }
guard granted else { FileHandle.standardError.write("denied\n".data(using: .utf8)!); exit(1) }

let now = Date()
let predicate = store.predicateForEvents(withStart: now.addingTimeInterval(-3600),
                                         end: now.addingTimeInterval(hours * 3600),
                                         calendars: nil)
let events = store.events(matching: predicate)
    .filter { !$0.isAllDay && $0.calendar.type != .birthday && $0.calendar.type != .subscription }
    .filter { $0.status != .canceled }
    .filter { $0.attendees?.first(where: { $0.isCurrentUser })?.participantStatus != .declined }
    .sorted { $0.startDate < $1.startDate }

let clock = DateFormatter()
clock.dateFormat = "HH:mm"

func meet(_ text: String?) -> String? {
    guard let text = text,
          let range = text.range(of: #"https://meet\.google\.com/[a-z0-9-]+"#, options: .regularExpression)
    else { return nil }
    return String(text[range])
}

func clean(_ title: String) -> String {
    let scalars = title.unicodeScalars.map { $0.properties.generalCategory == .control || $0 == "\t" ? " " : Character($0) }
    let flat = String(scalars).trimmingCharacters(in: .whitespaces)
    return flat.count > 24 ? String(flat.prefix(23)) + "…" : flat
}

for event in events {
    let link = meet(event.url?.absoluteString) ?? meet(event.location) ?? meet(event.notes) ?? ""
    let fields = [String(Int(event.startDate.timeIntervalSince1970)),
                  String(Int(event.endDate.timeIntervalSince1970)),
                  link,
                  clock.string(from: event.startDate),
                  clean(event.title ?? "")]
    print(fields.joined(separator: "\t"))
}
