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
      },
      {
        matchPackagePatterns: ["helm"],
        groupName: "helm",
        automerge: true,
        automergeType: "branch"
      },
      {
        description: 'lockFileMaintenance',
        matchUpdateTypes: [
          'pin',
          'digest',
          'patch',
          'minor',
          'major',
          'lockFileMaintenance',
        ],
        stabilityDays: 0,
      },
    ],
  };
