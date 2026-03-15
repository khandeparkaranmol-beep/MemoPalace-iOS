import Foundation

/// Calls the Claude API to generate a memory palace from user concepts.
///
/// In production, this would call your Vercel serverless function (api/generate.js)
/// or call the Anthropic API directly. For now, it includes a mock fallback.
class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    /// Your deployed API endpoint (Vercel URL)
    /// Set this to your actual Vercel deployment URL
    private let apiURL = "https://YOUR-APP.vercel.app/api/generate"

    /// Anthropic API key — for direct API calls (alternative to Vercel backend)
    /// ⚠️ In production, NEVER ship API keys in the app. Use a backend proxy.
    private let anthropicAPIKey = ""  // Leave empty to use mock data

    func generate(concepts: String) async throws -> Palace {
        // If no API key or URL configured, fall back to mock data
        if anthropicAPIKey.isEmpty && apiURL.contains("YOUR-APP") {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_500_000_000)
            return MockData.krebsCyclePalace
        }

        // ── Direct Anthropic API call ──
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue(anthropicAPIKey, forHTTPHeaderField: "x-api-key")

        let prompt = buildPrompt(concepts: concepts)
        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 8000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError("API returned non-200 status")
        }

        // Parse Claude's response
        let apiResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let textContent = apiResponse.content.first?.text else {
            throw APIError.parseError("No text in response")
        }

        // Extract JSON from the response
        guard let jsonStart = textContent.range(of: "{"),
              let jsonEnd = textContent.range(of: "}", options: .backwards) else {
            throw APIError.parseError("No JSON found in response")
        }

        let jsonString = String(textContent[jsonStart.lowerBound...jsonEnd.upperBound])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw APIError.parseError("Could not convert JSON string")
        }

        return try JSONDecoder().decode(Palace.self, from: jsonData)
    }

    private func buildPrompt(concepts: String) -> String {
        """
        You are a memory palace architect. Given a set of concepts, generate a JSON memory palace.

        For each concept, create a vivid, memorable 3D voxel object using the Method of Loci technique.
        Each object should be a visual mnemonic that helps the learner remember the concept.

        Return ONLY valid JSON in this exact format:
        {
          "theme": "Palace title",
          "rooms": [
            {
              "name": "Room name",
              "concepts": [
                {
                  "label": "Concept name",
                  "originalText": "The original concept text",
                  "association": "Description of the mnemonic object and why it helps remember",
                  "voxels": [
                    { "x": 0, "y": 0, "z": 0, "color": "#FF8800" },
                    { "x": 0, "y": 1, "z": 0, "color": "#FF8800", "emissive": "#FF6600", "emissiveIntensity": 2.0, "animate": "pulse" }
                  ],
                  "glowColor": "#FF8800"
                }
              ]
            }
          ]
        }

        Voxel coordinates should range roughly -8 to 8 on X/Z and 0 to 18 on Y.
        Use "animate": "pulse" for glowing cores, "flicker" for sparks/fire, "drift" for smoke/steam.
        Make objects recognizable: if it's an orange, make it look like an orange. If it's an ox, give it horns and legs.
        4-6 concepts per room. Color objects vividly.

        Concepts to memorize:
        \(concepts)
        """
    }

    enum APIError: LocalizedError {
        case invalidURL
        case serverError(String)
        case parseError(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid API URL"
            case .serverError(let msg): return "Server error: \(msg)"
            case .parseError(let msg): return "Parse error: \(msg)"
            }
        }
    }
}

// Anthropic API response structure
struct AnthropicResponse: Codable {
    let content: [ContentBlock]

    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }
}
