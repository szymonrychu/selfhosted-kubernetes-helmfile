module.exports = {
    dryRun: false,
    username: 'szymonrichert.pl bot',
    gitAuthor: 'szymonrichert.pl bot <bot@szymonrichert.pl>',
    onboarding: false,
    platform: 'github',
    repositories: [
      'szymonrychu/helmfile-cluster',
    ],
    packageRules: [
      {
        dependencyDashboardApproval: false,
        description: 'MinorAutoUpgrade',
        matchUpdateTypes: [
          'pin',
          'digest',
          'patch',
          'minor',
          'major'
        ],
        automerge: true,
        automergeType: "pr",
        addLabels: ["automerge"],
        stabilityDays: 0,
      },
      {
        dependencyDashboardApproval: false,
        description: 'MajorUpgrade',
        matchUpdateTypes: [
          'major'
        ],
        stabilityDays: 7,
      },
    ],
  };
