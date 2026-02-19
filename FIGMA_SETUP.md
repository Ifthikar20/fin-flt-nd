# Figma MCP Integration - Fynda App

This project is configured to use Figma's remote MCP server, which lets Claude Code read Figma design files and generate/update Flutter code to match your designs.

## How It Works

The `.mcp.json` file in this project root connects Claude Code to Figma's MCP server at `https://mcp.figma.com/mcp`. Once connected, you can paste a Figma frame URL and ask Claude to implement it as Flutter code.

## Setup (One-Time)

### 1. Create a Figma Account
Go to [figma.com](https://figma.com) and sign up for a free account if you don't have one.

### 2. Connect Claude Code to Figma

In your terminal (inside this project), run:

```bash
claude mcp add --transport http figma https://mcp.figma.com/mcp
```

Then restart Claude Code if it is already running.

### 3. Authenticate with Figma

In a Claude Code session, run `/mcp` to see connected servers. If `figma` shows as disconnected, press Enter on it to open the Figma login/authorization page in your browser. Click **Allow Access** when prompted.

### 4. Confirm the Connection

Run `/mcp` again — the `figma` server should show as **connected**.

---

## Using Figma with Claude Code

Once connected, you can interact with your Figma designs in two ways:

### Option A — Share a Figma Link
Copy the link to any Figma frame (right-click a frame → Copy link) and paste it in a Claude Code prompt:

```
Implement the design at this Figma link as a Flutter screen:
https://www.figma.com/design/...
```

### Option B — Reference the Current Selection (Desktop App)
If you have the Figma desktop app, select a frame or component and then ask:

```
Implement my currently selected Figma frame as a Flutter widget,
using the existing app_theme.dart design tokens.
```

---

## Fynda App Design System

When asking Claude to generate Flutter code from Figma designs, reference the existing design tokens to keep things consistent:

| Token | Value | File |
|---|---|---|
| Font | Outfit (Google Fonts) | `lib/theme/app_theme.dart` |
| Primary color | `#1A1A1A` | `lib/theme/app_theme.dart` |
| Background | `#FFFFFF` / `#F5F5F7` | `lib/theme/app_theme.dart` |
| Border radius sm/md/lg/xl | 8/12/16/24px | `lib/theme/app_theme.dart` |

### Example Prompt

```
Implement the Figma frame at [link] as a Flutter screen.
- Use the existing AppTheme from lib/theme/app_theme.dart for colors, fonts, and spacing
- Follow the BLoC pattern used in the rest of the app
- Match the widget structure of lib/screens/home_screen.dart as a reference
```

---

## Screens in This App

For reference, these are the existing screens that could be redesigned via Figma:

| Screen | File |
|---|---|
| Splash | `lib/screens/splash_screen.dart` |
| Onboarding | `lib/screens/onboarding_screen.dart` |
| Login | `lib/screens/login_screen.dart` |
| Register | `lib/screens/register_screen.dart` |
| Home (trending deals) | `lib/screens/home_screen.dart` |
| Camera (image search) | `lib/screens/camera_screen.dart` |
| Image search results | `lib/screens/image_results_screen.dart` |
| Text search results | `lib/screens/search_results_screen.dart` |
| Product detail | `lib/screens/product_detail_screen.dart` |
| Favorites | `lib/screens/favorites_screen.dart` |
| Fashion boards | `lib/screens/fashion_board_screen.dart` |
| Board editor | `lib/screens/fashion_board_editor.dart` |
| Board share | `lib/screens/fashion_board_share_screen.dart` |
| Brand page | `lib/screens/brand_screen.dart` |
| Profile | `lib/screens/profile_screen.dart` |

---

## Resources

- [Figma MCP Server docs](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/)
- [Figma MCP setup guide](https://help.figma.com/hc/en-us/articles/35281350665623-Figma-MCP-collection-How-to-set-up-the-Figma-remote-MCP-server)
- [Claude Code + Figma guide](https://www.builder.io/blog/claude-code-figma-mcp-server)
