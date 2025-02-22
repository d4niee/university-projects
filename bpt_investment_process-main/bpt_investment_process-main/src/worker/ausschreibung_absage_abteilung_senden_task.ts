// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ausschreibung_absage_abteilung_senden_task(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-absage-abteilung-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung-abgelehnt-lieferant-message",
          correlationKey: "ausschreibung_abgelehnt_lieferant_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  