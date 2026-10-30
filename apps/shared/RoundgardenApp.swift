import RoundgardenCore
import SwiftUI

@main
struct RoundgardenApp: App {
  var body: some Scene {
    WindowGroup {
      RoundgardenRootView()
    }
  }
}

private struct RoundgardenRootView: View {
  @State private var isPlaying = false
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    Group {
      if isPlaying {
        GardenGameView {
          isPlaying = false
        }
        .transition(.opacity)
      } else {
        GardenMenuView {
          isPlaying = true
        }
        .transition(.opacity)
      }
    }
    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: isPlaying)
    .preferredColorScheme(.dark)
  }
}

private struct GardenMenuView: View {
  let onPlay: () -> Void
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.colorSchemeContrast) private var colorContrast

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.06, green: 0.14, blue: 0.11), Color(red: 0.012, green: 0.032, blue: 0.031),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 22) {
        Image(systemName: "leaf.circle")
          .font(.system(size: 54, weight: .ultraLight))
          .foregroundStyle(Color(red: 0.78, green: 0.9, blue: 0.63))
          .accessibilityHidden(true)

        VStack(spacing: 8) {
          Text("roundgarden")
            .font(.system(size: 38, weight: .medium, design: .serif))
            .tracking(-1)
          Text("The garden goes all the way around.")
            .font(.system(size: 27, weight: .medium, design: .serif))
            .multilineTextAlignment(.center)
          Text(
            "Float inside a whimsical garden that surrounds you. Look all around as strange garden oddities drift close."
          )
          .font(.system(size: 15, weight: .regular, design: .rounded))
          .multilineTextAlignment(.center)
          .foregroundStyle(colorContrast == .increased ? .white : .white.opacity(0.82))
          .frame(maxWidth: 440)
        }

        Button(action: onPlay) {
          Label("Enter the garden", systemImage: "arrow.right")
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .frame(minWidth: 220, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(red: 0.45, green: 0.61, blue: 0.34))
        .accessibilityHint("Opens the garden. Drag anywhere in the garden to look around.")
        #if os(macOS)
          .keyboardShortcut(.defaultAction)
        #endif
      }
      .padding(32)
    }
    .background(reduceTransparency ? Color.black.opacity(0.94) : Color.clear)
  }
}

private struct GardenGameView: View {
  let onExit: () -> Void
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.colorSchemeContrast) private var colorContrast
  @State private var round = RoundState(
    personalBest: UserDefaults.standard.integer(forKey: "roundgarden.personalBest"))
  @State private var lastAwardPoints: Int?
  @State private var awardCount = 0

  var body: some View {
    ZStack {
      GardenSceneView(round: round) { value, distance in
        guard let points = round.vaporize(value: value, distance: distance) else { return }
        lastAwardPoints = points
        awardCount += 1
      }

      VStack {
        HStack {
          Button(action: onExit) {
            Label("Menu", systemImage: "chevron.left")
              .frame(minWidth: 44, minHeight: 44)
          }
          .accessibilityHint("Returns to the Roundgarden menu.")

          Spacer()

          VStack(alignment: .trailing, spacing: 2) {
            Text("SCORE  ·  \(round.score.formatted())")
              .font(.system(size: 11, weight: .semibold, design: .rounded))
              .tracking(1.2)
              .accessibilityLabel(Text("Score \(round.score.formatted()) points"))
              .accessibilityIdentifier("round-score")
            Text(timerText)
              .font(.system(size: 24, weight: .medium, design: .rounded).monospacedDigit())
              .accessibilityLabel(Text("\(Int(ceil(round.remainingTime))) seconds remaining"))
              .accessibilityIdentifier("round-timer")
          }

          Button(action: togglePause) {
            Label(
              round.phase == .paused ? "Resume" : "Pause",
              systemImage: round.phase == .paused ? "play.fill" : "pause.fill"
            )
            .frame(minWidth: 44, minHeight: 44)
          }
          .disabled(round.phase == .ready || round.phase == .complete)
          .accessibilityHint(
            round.phase == .paused ? "Resumes the round." : "Pauses the round and garden motion."
          )
          #if os(macOS)
            .keyboardShortcut(.escape, modifiers: [])
          #endif
        }
        .buttonStyle(.bordered)
        .tint(.white.opacity(0.9))
        .padding(.horizontal, 20)
        .padding(.top, 8)

        Spacer()

        if round.phase == .playing || round.phase == .ready {
          VStack(spacing: 5) {
            Text(instructionText)
              .font(.system(size: 12, weight: .semibold, design: .rounded))
              .tracking(1.1)
            if let lastAwardPoints {
              Text("\(lastAwardPoints.formatted()) points · vaporized into light")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .accessibilityLabel(
                  Text("Vaporized into light. \(lastAwardPoints.formatted()) points."))
            }
          }
          .font(.system(size: 15, weight: .medium, design: .rounded))
          .foregroundStyle(.white.opacity(0.9))
          .padding(.horizontal, 18)
          .padding(.vertical, 10)
          .background(
            .black.opacity(colorContrast == .increased ? 0.82 : 0.66), in: Capsule()
          )
          .padding(.bottom, 22)
        }
      }

      if round.phase == .ready || round.phase == .paused || round.phase == .complete {
        roundOverlay
      }
    }
    .background(Color(red: 0.012, green: 0.032, blue: 0.031).ignoresSafeArea())
    .sensoryFeedback(.success, trigger: awardCount)
    .task {
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(100))
        round.advance(by: 0.1)
      }
    }
    .onChange(of: scenePhase) { _, phase in
      if phase != .active { round.pause() }
    }
    .onChange(of: round.phase) { _, phase in
      if phase == .complete {
        UserDefaults.standard.set(round.personalBest, forKey: "roundgarden.personalBest")
      }
    }
  }

  private var timerText: String {
    let seconds = Int(ceil(round.remainingTime))
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }

  private var roundOverlay: some View {
    VStack(spacing: 14) {
      if round.phase == .ready {
        Text("Ready to wander?")
          .font(.system(size: 28, weight: .medium, design: .serif))
        Text("Look around and vaporize the garden oddities before they drift away.")
          .font(.system(size: 15, weight: .regular, design: .rounded))
          .multilineTextAlignment(.center)
          .foregroundStyle(.white.opacity(0.8))
        Button("Start 60-second round") { round.start() }
          .buttonStyle(.borderedProminent)
          .tint(Color(red: 0.45, green: 0.61, blue: 0.34))
          .frame(minHeight: 48)
      } else if round.phase == .paused {
        Text("Round paused")
          .font(.system(size: 28, weight: .medium, design: .serif))
        Button("Resume round") { round.resume() }
          .buttonStyle(.borderedProminent)
          .tint(Color(red: 0.45, green: 0.61, blue: 0.34))
          .frame(minHeight: 48)
      } else {
        Text("One minute, gone in a blink.")
          .font(.system(size: 28, weight: .medium, design: .serif))
          .multilineTextAlignment(.center)
        Text("Final score  ·  \(round.score.formatted())")
          .font(.system(size: 18, weight: .semibold, design: .rounded))
        Text("Personal best  ·  \(round.personalBest.formatted())")
          .font(.system(size: 15, weight: .regular, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
          .accessibilityLabel(Text("Personal best \(round.personalBest.formatted()) points"))
        Button("Go around again") { round.start() }
          .buttonStyle(.borderedProminent)
          .tint(Color(red: 0.45, green: 0.61, blue: 0.34))
          .frame(minHeight: 48)
      }
    }
    .padding(24)
    .frame(maxWidth: 340)
    .background(
      .black.opacity(reduceTransparency || colorContrast == .increased ? 0.94 : 0.82),
      in: RoundedRectangle(cornerRadius: 24)
    )
    .padding(24)
    .accessibilityElement(children: .contain)
  }

  private func togglePause() {
    if round.phase == .paused {
      round.resume()
    } else {
      round.pause()
    }
  }

  private var instructionText: LocalizedStringKey {
    #if os(macOS)
      "DRAG TO LOOK  ·  CLICK TO VAPORIZE"
    #else
      "DRAG TO LOOK  ·  TAP TO VAPORIZE"
    #endif
  }
}
