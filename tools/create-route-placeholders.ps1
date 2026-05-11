$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

function Get-RelativePathToRoot {
    param([string]$Route)

    $parts = $Route -split "[/\\]" | Where-Object { $_ -ne "" }
    if ($parts.Count -eq 0) {
        return "."
    }

    return (($parts | ForEach-Object { ".." }) -join "/")
}

function New-RoutePage {
    param(
        [string]$Route,
        [string]$Title,
        [string]$Description,
        [string]$RedirectTo = ""
    )

    $routePath = Join-Path $root $Route
    New-Item -ItemType Directory -Force -Path $routePath | Out-Null

    $rootRel = Get-RelativePathToRoot $Route
    $homeHref = if ($rootRel -eq ".") { "./" } else { "$rootRel/" }
    $metaRefresh = ""
    $redirectNote = ""

    if ($RedirectTo -ne "") {
        $metaRefresh = "  <meta http-equiv=""refresh"" content=""0; url=$RedirectTo"">`r`n"
        $redirectNote = "<p class=""route-note"">Redirecting to <a href=""$RedirectTo"">$RedirectTo</a>.</p>"
    }

    $html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$Title &bull; DBDCompNet</title>
$metaRefresh  <style>
    :root { color-scheme: dark; --bg:#070709; --panel:#111116; --text:#fff; --muted:#b8b8c2; --red:#e11d2e; --border:rgba(255,255,255,.12); }
    * { box-sizing: border-box; }
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: radial-gradient(900px 480px at 20% 0%, rgba(225,29,46,.18), transparent 50%), var(--bg); color: var(--text); font: 16px/1.6 "Lexend", "Segoe UI", sans-serif; }
    main { width: min(92vw, 760px); padding: 44px; border: 1px solid var(--border); background: linear-gradient(180deg, rgba(255,255,255,.05), rgba(255,255,255,.02)); border-radius: 12px; box-shadow: 0 24px 80px rgba(0,0,0,.35); }
    .kicker { margin: 0 0 10px; color: var(--red); font-size: 12px; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; }
    h1 { margin: 0 0 12px; font-size: clamp(30px, 5vw, 48px); line-height: 1.05; }
    p { margin: 0 0 16px; color: var(--muted); }
    a { color: #fff; }
    .route { margin-top: 22px; padding: 14px 16px; border: 1px solid var(--border); border-radius: 8px; color: #fff; background: rgba(255,255,255,.04); font-family: Consolas, monospace; overflow-wrap: anywhere; }
    .actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 24px; }
    .btn { display: inline-flex; align-items: center; justify-content: center; min-height: 42px; padding: 0 16px; border-radius: 8px; border: 1px solid var(--border); text-decoration: none; font-weight: 800; }
    .btn-primary { background: var(--red); border-color: var(--red); }
    .route-note { color: #fff; }
  </style>
</head>
<body>
  <main>
    <p class="kicker">Routing placeholder</p>
    <h1>$Title</h1>
    <p>$Description</p>
    $redirectNote
    <div class="route">$Route/</div>
    <div class="actions">
      <a class="btn btn-primary" href="$homeHref">Home</a>
      <a class="btn" href="$homeHref`demo/">Site Directory</a>
    </div>
  </main>
</body>
</html>
"@

    Set-Content -LiteralPath (Join-Path $routePath "index.html") -Value $html -Encoding UTF8
}

$routes = @(
    @{ Route = "account/myteam"; Title = "MyTeam"; Description = "Compatibility route for the account-side team management area."; RedirectTo = "../../myteam/" },
    @{ Route = "account/myteam/suspensions"; Title = "Active Suspensions"; Description = "Compatibility route for account-side suspension views."; RedirectTo = "../../../myteam/suspensions/" },
    @{ Route = "account/myteam/suspensions/appeal-request"; Title = "Appeal Request"; Description = "Placeholder route for starting a suspension appeal request." },
    @{ Route = "account/myteam/settings"; Title = "MyTeam Settings"; Description = "Compatibility route for team/account settings."; RedirectTo = "../../../account/settings/" },
    @{ Route = "account/myteam/organizations"; Title = "My Organizations"; Description = "Compatibility route for organization memberships."; RedirectTo = "../../../myteam/orgs/" },
    @{ Route = "account/myteam/invites"; Title = "Invites"; Description = "Placeholder route for account invitation inbox." },
    @{ Route = "account/myteam/invites/INVITE_ID"; Title = "Invite Details"; Description = "Placeholder route for viewing a specific invite." },
    @{ Route = "account/support-tickets"; Title = "Support Tickets"; Description = "Placeholder route for account support tickets." },
    @{ Route = "account/support-tickets/TICKET_ID"; Title = "Support Ticket"; Description = "Placeholder route for viewing a specific account ticket." },
    @{ Route = "teams/TEAM_ID"; Title = "Team Profile"; Description = "Placeholder route for a team profile identified by TEAM_ID." },
    @{ Route = "teams/TEAM_ID/application"; Title = "Team Application"; Description = "Placeholder route for applying to a team." },
    @{ Route = "news/post/POST_ID"; Title = "News Post"; Description = "Placeholder route for a news post identified by POST_ID." },
    @{ Route = "tournaments/TOURNAMENT-ID"; Title = "Tournament Details"; Description = "Placeholder route for a tournament identified by TOURNAMENT-ID." },
    @{ Route = "tournaments/calendar-view"; Title = "Tournament Calendar"; Description = "Compatibility route for the tournament calendar."; RedirectTo = "../calendar_view/" },
    @{ Route = "intern"; Title = "Organization Intern Area"; Description = "Placeholder entry point for organization intern routes." },
    @{ Route = "intern/UUID-OF-ORG"; Title = "Organization Intern Home"; Description = "Placeholder organization home route for UUID-OF-ORG." },
    @{ Route = "intern/UUID-OF-ORG/teams"; Title = "Organization Teams"; Description = "Placeholder organization teams route." },
    @{ Route = "intern/UUID-OF-ORG/teams/TEAM_ID"; Title = "Organization Team"; Description = "Placeholder organization team route." },
    @{ Route = "intern/UUID-OF-ORG/tournaments"; Title = "Organization Tournaments"; Description = "Placeholder organization tournaments route." },
    @{ Route = "intern/UUID-OF-ORG/tournaments/TOURNAMENT_ID"; Title = "Organization Tournament"; Description = "Placeholder organization tournament route." },
    @{ Route = "intern/UUID-OF-ORG/tournaments/TOURNAMENT_ID/register"; Title = "Tournament Register"; Description = "Placeholder tournament registration route." },
    @{ Route = "intern/UUID-OF-ORG/ap"; Title = "Organization Admin Panel"; Description = "Compatibility route for the organization admin panel."; RedirectTo = "../../../ap/" },
    @{ Route = "intern/UUID-OF-ORG/ap/tournaments"; Title = "AP Tournaments"; Description = "Compatibility route for AP tournaments."; RedirectTo = "../../../../ap/tournaments/" },
    @{ Route = "intern/UUID-OF-ORG/ap/tournaments/create"; Title = "Create Tournament"; Description = "Compatibility route for creating an AP tournament."; RedirectTo = "../../../../../ap/tournaments/create/" },
    @{ Route = "intern/UUID-OF-ORG/ap/tournaments/TOURNAMENT_ID/edit"; Title = "Edit Tournament"; Description = "Compatibility route for editing an AP tournament."; RedirectTo = "../../../../../../ap/tournaments/tournament-name/edit/" },
    @{ Route = "intern/UUID-OF-ORG/ap/teams"; Title = "AP Teams"; Description = "Compatibility route for AP teams."; RedirectTo = "../../../../ap/teams/" },
    @{ Route = "intern/UUID-OF-ORG/ap/access"; Title = "AP Access"; Description = "Compatibility route for AP access."; RedirectTo = "../../../../ap/access/" },
    @{ Route = "intern/UUID-OF-ORG/ap/news"; Title = "AP News"; Description = "Compatibility route for AP news."; RedirectTo = "../../../../ap/news/" },
    @{ Route = "intern/UUID-OF-ORG/ap/news/create"; Title = "Create News"; Description = "Compatibility route for creating AP news."; RedirectTo = "../../../../../ap/news/create/" },
    @{ Route = "intern/UUID-OF-ORG/ap/news/NEWS_ID"; Title = "AP News Item"; Description = "Placeholder route for an organization news item." },
    @{ Route = "intern/UUID-OF-ORG/ap/settings"; Title = "AP Settings"; Description = "Compatibility route for AP settings."; RedirectTo = "../../../../ap/settings/" },
    @{ Route = "forums"; Title = "Forums"; Description = "Placeholder route for public and organization forum categories." },
    @{ Route = "forums/CATEGORY_NAME"; Title = "Forum Category"; Description = "Placeholder route for a forum category." },
    @{ Route = "forums/CATEGORY_NAME/FORUM_POST_ID"; Title = "Forum Post"; Description = "Placeholder route for a forum post." },
    @{ Route = "forums/new-post"; Title = "Create Forum Post"; Description = "Placeholder route for creating a forum post." },
    @{ Route = "forums/manager-mode"; Title = "Forum Manager"; Description = "Placeholder route for forum manager mode." },
    @{ Route = "forums/manager-mode/overview"; Title = "Forum Manager Overview"; Description = "Placeholder route for forum manager overview." },
    @{ Route = "forums/manager-mode/FORUM_ID/delete-post"; Title = "Delete Forum Post"; Description = "Placeholder route for deleting a forum post." },
    @{ Route = "forums/manager-mode/creator-menu"; Title = "Creator Menu"; Description = "Placeholder route for forum creator tools." },
    @{ Route = "forums/manager-mode/creator-menu/new-category"; Title = "New Category"; Description = "Placeholder route for creating a forum category." },
    @{ Route = "forums/manager-mode/creator-menu/CATEGORY_NAME/delete"; Title = "Delete Category"; Description = "Placeholder route for deleting a forum category." },
    @{ Route = "admin/ap"; Title = "DBDCompNet Admin"; Description = "Compatibility route for the DBDCompNet admin panel."; RedirectTo = "../../admin/" },
    @{ Route = "admin/ap/organizations"; Title = "Admin Organizations"; Description = "Compatibility route for admin organizations."; RedirectTo = "../../../admin/organizations/" },
    @{ Route = "admin/ap/organizations/new"; Title = "Create Organization"; Description = "Compatibility route for creating an organization."; RedirectTo = "../../../../admin/organizations/create/" },
    @{ Route = "admin/ap/organizations/UUID-OF-ORG/access"; Title = "Organization Access"; Description = "Compatibility route for organization permissions."; RedirectTo = "../../../../../admin/organizations/perms/" },
    @{ Route = "admin/ap/users"; Title = "Admin Users"; Description = "Compatibility route for admin users."; RedirectTo = "../../../admin/users/" },
    @{ Route = "admin/ap/users/UUID-OF-USER"; Title = "Admin User"; Description = "Placeholder route for viewing an admin user." },
    @{ Route = "admin/ap/users/UUID-OF-USER/actions"; Title = "User Actions"; Description = "Compatibility route for user action tools."; RedirectTo = "../../../../../admin/users/uuid-of-user/actions/" },
    @{ Route = "admin/ap/tournaments"; Title = "Admin Tournaments"; Description = "Compatibility route for admin tournaments."; RedirectTo = "../../../admin/tournaments/" },
    @{ Route = "admin/ap/tournaments/create"; Title = "Create Tournament"; Description = "Compatibility route for admin tournament creation."; RedirectTo = "../../../../admin/tournaments/create/" },
    @{ Route = "admin/ap/tournaments/TOURNAMENT_ID/edit"; Title = "Edit Tournament"; Description = "Compatibility route for admin tournament editing."; RedirectTo = "../../../../../admin/tournaments/tournament-name/edit/" },
    @{ Route = "admin/ap/news"; Title = "Admin News"; Description = "Compatibility route for admin news."; RedirectTo = "../../../admin/news/" },
    @{ Route = "admin/ap/news/create"; Title = "Create News"; Description = "Compatibility route for admin news creation."; RedirectTo = "../../../../admin/news/create/" },
    @{ Route = "admin/ap/news/NEWS_ID/edit"; Title = "Edit News"; Description = "Compatibility route for admin news editing."; RedirectTo = "../../../../../admin/news/article-header/edit/" },
    @{ Route = "admin/ap/support"; Title = "Admin Support"; Description = "Compatibility route for admin support."; RedirectTo = "../../../admin/support/" },
    @{ Route = "admin/ap/support/create"; Title = "Create Support"; Description = "Compatibility route for support creation."; RedirectTo = "../../../../admin/support/create/" },
    @{ Route = "admin/ap/support/create/support_category"; Title = "Create Support Category"; Description = "Compatibility route for support category creation."; RedirectTo = "../../../../../admin/support/create/category/" },
    @{ Route = "admin/ap/support/article-header"; Title = "Support Article"; Description = "Placeholder route for viewing a support article." },
    @{ Route = "admin/ap/support/tickets"; Title = "Support Tickets"; Description = "Placeholder route for admin support tickets." },
    @{ Route = "admin/ap/support/tickets/TICKET_ID"; Title = "Support Ticket"; Description = "Placeholder route for viewing or answering a support ticket." },
    @{ Route = "support/CATEGORY_NAME/ARTICLE_NAME"; Title = "Support Article"; Description = "Placeholder support article route." },
    @{ Route = "support/accounts/tickets/appeal-ticket"; Title = "Appeal Ticket"; Description = "Placeholder support account appeal ticket route." },
    @{ Route = "balancing"; Title = "Balancing"; Description = "Upcoming balancing area planned for late 2026 / early 2027." },
    @{ Route = "balancing/overview"; Title = "Balancing Overview"; Description = "Placeholder route for balancing overview." },
    @{ Route = "balancing/overview/BALANCING_ID"; Title = "Balancing Item"; Description = "Placeholder route for a balancing item." },
    @{ Route = "balancing/build-creator"; Title = "Build Creator"; Description = "Placeholder route for balancing build creation." },
    @{ Route = "balancing/build-creator/BALANCING_ID/build"; Title = "Build"; Description = "Placeholder route for a balancing build." },
    @{ Route = "balancing/build-creator/BALANCING_ID/build/generate-image"; Title = "Generate Image"; Description = "Placeholder route for generating a build image." },
    @{ Route = "easybalancing/UUID-OF-ORG/home"; Title = "EasyBalancing Home"; Description = "Placeholder organization easy balancing route." },
    @{ Route = "easybalancing/UUID-OF-ORG/new-balancing"; Title = "New Balancing"; Description = "Placeholder route for creating organization balancing." },
    @{ Route = "easybalancing/UUID-OF-ORG/BALANCING_ID/edit-manager"; Title = "Edit Balancing"; Description = "Placeholder route for balancing edit management." },
    @{ Route = "easybalancing/UUID-OF-ORG/BALANCING_ID/delete"; Title = "Delete Balancing"; Description = "Placeholder route for deleting balancing." },
    @{ Route = "ranked"; Title = "Ranked"; Description = "Placeholder route for ranked play." },
    @{ Route = "ranked/leaderboard"; Title = "Ranked Leaderboard"; Description = "Placeholder route for the ranked leaderboard." },
    @{ Route = "ranked/queue"; Title = "Ranked Queue"; Description = "Placeholder route for ranked queue." },
    @{ Route = "ranked/queue/looking-for-lobby"; Title = "Looking for Lobby"; Description = "Placeholder route for ranked lobby search." },
    @{ Route = "ranked/TEMPORARY_LOBBY_ID"; Title = "Ranked Lobby"; Description = "Placeholder route for a temporary ranked lobby." },
    @{ Route = "ranked/TEMPORARY_LOBBY_ID/chatroom"; Title = "Ranked Chatroom"; Description = "Placeholder route for a ranked lobby chatroom." },
    @{ Route = "ranked/profile"; Title = "Ranked Profile"; Description = "Placeholder route for the current user's ranked profile." },
    @{ Route = "ranked/profile/UUID-OF-USER"; Title = "Ranked User Profile"; Description = "Placeholder route for another user's ranked profile." },
    @{ Route = "rs"; Title = "Rating System"; Description = "Placeholder route for the rating system." },
    @{ Route = "rs/search"; Title = "Rating Search"; Description = "Placeholder route for searching ratings." },
    @{ Route = "rs/score/TEAM_NAME"; Title = "Team Rating"; Description = "Placeholder route for a team rating score." },
    @{ Route = "rs/score/UUID-OF-USER"; Title = "User Rating"; Description = "Placeholder route for a user rating score." },
    @{ Route = "rs/score/UUID-OF-ORG"; Title = "Organization Rating"; Description = "Placeholder route for an organization rating score." },
    @{ Route = "rs/profile/UUID-OF-ORG/tournaments"; Title = "Organization Rating Tournaments"; Description = "Placeholder route for organization rating eligibility." },
    @{ Route = "rs/rating/TEAM_NAME"; Title = "Rate Team"; Description = "Placeholder route for rating a team." },
    @{ Route = "rs/rating/TEAM_NAME/new-rating"; Title = "New Team Rating"; Description = "Placeholder route for submitting a team rating." },
    @{ Route = "rs/rating/UUID-OF-USER"; Title = "Rate Player"; Description = "Placeholder route for rating a player." },
    @{ Route = "rs/rating/UUID-OF-USER/new-rating"; Title = "New Player Rating"; Description = "Placeholder route for submitting a player rating." },
    @{ Route = "rs/rating/UUID-OF-ORG"; Title = "Rate Organization"; Description = "Placeholder route for rating an organization." },
    @{ Route = "rs/rating/UUID-OF-ORG/new-rating"; Title = "New Organization Rating"; Description = "Placeholder route for submitting an organization rating." },
    @{ Route = "awards"; Title = "Awards"; Description = "Placeholder route for DBDCompNet awards." }
)

foreach ($route in $routes) {
    New-RoutePage @route
}

Write-Host "Created or updated $($routes.Count) route placeholder pages."
