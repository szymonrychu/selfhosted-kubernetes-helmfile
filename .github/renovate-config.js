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
        description: 'lockFileMaintenance',
        matchUpdateTypes: [
          'pin',
          'digest',
          'patch',
          'minor',
          'major',
          'lockFileMaintenance',
        ],
        automerge: true,
        automergeType: "branch",
        addLabels: ["automerge"],
        stabilityDays: 0,
      },
    ],
  };
