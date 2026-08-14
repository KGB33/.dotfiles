{ inputs, ... }:
{
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  apps.pi.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      piPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;

      cherryVersion = "0.6.38";
      cherryArchive = pkgs.fetchurl {
        url = "https://registry.npmjs.org/cherry-cljs/-/cherry-cljs-${cherryVersion}.tgz";
        hash = "sha512-IgTWS+e1tA1YcqPOzG65AZJ/Plonz5aXiVSLuvgntlbar4atz3W6klHDnV8u7mi96HJCumoAQg1VutXkMABQdg==";
      };
      cherrySource = pkgs.runCommand "cherry-cljs-${cherryVersion}-source" { } ''
        mkdir "$out"
        tar -xzf ${cherryArchive} --strip-components=1 -C "$out"
        ${pkgs.jq}/bin/jq 'del(.devDependencies)' "$out/package.json" > package.json
        mv package.json "$out/package.json"
        cp ${./pi/package-lock.json} "$out/package-lock.json"
      '';
      cherry = pkgs.buildNpmPackage {
        pname = "cherry-cljs";
        version = cherryVersion;
        src = cherrySource;
        npmDepsHash = "sha256-b0fKOcw/r6ave9It5m+zZAPpOrxecEgqeLuTtYb9fgk=";
        dontNpmBuild = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          runHook preInstall
          mkdir -p "$out/bin" "$out/lib/node_modules"
          cp -r . "$out/lib/node_modules/cherry-cljs"
          makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/cherry" \
            --add-flags "$out/lib/node_modules/cherry-cljs/node_cli.js"
          runHook postInstall
        '';
      };
      cherryPackage = "${cherry}/lib/node_modules/cherry-cljs";
      cherryCompiler = pkgs.writeText "compile-cherry-extension.mjs" ''
        import { readFile, writeFile } from "node:fs/promises";
        import { compileString } from "${cherryPackage}/lib/compiler.node.js";

        const [sourcePath, outputPath] = process.argv.slice(2);
        const source = await readFile(sourcePath, "utf8");
        const result = await compileString(source, {});

        if (!result.exports.includes("export default")) {
          throw new Error(`Pi extension ''${sourcePath} does not export a default function`);
        }

        await writeFile(outputPath, result.javascript);
      '';
      compileClojureScript =
        name: source:
        pkgs.runCommand name { nativeBuildInputs = [ pkgs.nodejs ]; } ''
          node ${cherryCompiler} ${source} "$out"
        '';

      colors = config.lib.stylix.colors.withHashtag;
      piTheme = {
        "$schema" =
          "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
        name = "stylix";
        vars = {
          inherit (colors)
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };
        colors = {
          accent = "base0D";
          border = "base04";
          borderAccent = "base0D";
          borderMuted = "base02";
          success = "base0B";
          error = "base08";
          warning = "base0A";
          muted = "base04";
          dim = "base03";
          text = "base05";
          thinkingText = "base04";

          selectedBg = "base02";
          scrollbarThumb = "base03";
          userMessageBg = "base01";
          userMessageText = "base05";
          customMessageBg = "base01";
          customMessageText = "base05";
          customMessageLabel = "base0D";
          toolPendingBg = "base01";
          toolSuccessBg = "base01";
          toolErrorBg = "base01";
          toolTitle = "base0D";
          toolOutput = "base05";

          mdHeading = "base09";
          mdLink = "base0D";
          mdLinkUrl = "base04";
          mdCode = "base0C";
          mdCodeBlock = "base05";
          mdCodeBlockBorder = "base03";
          mdQuote = "base04";
          mdQuoteBorder = "base03";
          mdHr = "base03";
          mdListBullet = "base0C";

          toolDiffAdded = "base0B";
          toolDiffRemoved = "base08";
          toolDiffContext = "base04";

          syntaxComment = "base03";
          syntaxKeyword = "base0E";
          syntaxFunction = "base0D";
          syntaxVariable = "base08";
          syntaxString = "base0B";
          syntaxNumber = "base09";
          syntaxType = "base0A";
          syntaxOperator = "base05";
          syntaxPunctuation = "base04";

          thinkingOff = "base03";
          thinkingMinimal = "base04";
          thinkingLow = "base0D";
          thinkingMedium = "base0C";
          thinkingHigh = "base0E";
          thinkingXhigh = "base08";
          thinkingMax = "base09";
          bashMode = "base0A";
        };
        export = {
          pageBg = colors.base00;
          cardBg = colors.base01;
          infoBg = colors.base02;
        };
      };
      piConfigDir = config.programs.pi-coding-agent.configDir;
    in
    {
      home.packages = [ cherry ];

      programs.pi-coding-agent = {
        enable = true;
        package = piPackage;
        extraPackages = [ pkgs.atuin ];
        settings = {
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.6-sol";
          defaultThinkingLevel = "high";
          theme = "stylix";
          skills = [ "${inputs.vibes}/plugins/workflow/skills" ];
          lastChangelogVersion = piPackage.version;
        };
      };

      home.file = {
        "${piConfigDir}/settings.json".force = true;
        "${piConfigDir}/themes/stylix.json" = {
          force = true;
          text = builtins.toJSON piTheme;
        };
        # Cherry output is JavaScript, not TypeScript. Giving it a .ts suffix
        # makes jiti's TypeScript parser reject valid generated JavaScript.
        "${piConfigDir}/extensions/atuin.js" = {
          force = true;
          source = compileClojureScript "pi-atuin-extension" ./pi/atuin.cljs;
        };
        "${piConfigDir}/extensions/tmux-status.js" = {
          force = true;
          source = compileClojureScript "pi-tmux-status-extension" ./pi/tmux-status.cljs;
        };

        # Resolve the compiled extensions' normal cherry-cljs runtime imports
        # from the same complete Cherry installation used by the compiler.
        "${piConfigDir}/extensions/node_modules/cherry-cljs".source = cherryPackage;
      };
    };
}
