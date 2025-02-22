// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ablehnungAusschreibungLieferantSendenAbteilungTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-absage-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung-abgelehnt-lieferant-message",
          correlationKey: "ausschreibung_abgelehnt_lieferant_key",
          variables: {
            start_event_reason: "ausschreibung_abgelehnt",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  