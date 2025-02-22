// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function zusageAusschreibungLieferantSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-lieferant-zusage-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung-zusage-erhalten-message",
          correlationKey: "ausschreibung_zusage_lieferant_key",
          variables: {
            start_event_reason: "ausschreibung_zugesagt",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  