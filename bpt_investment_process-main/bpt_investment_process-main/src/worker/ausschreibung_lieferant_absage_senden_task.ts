// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ablehnungAusschreibungLieferantSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-absage-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung-absage-erhalten-message",
          correlationKey: "ausschreibung_absage_lieferant_key",
          variables: {
            start_event_reason: "ausschreibung_abgelehnt",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  