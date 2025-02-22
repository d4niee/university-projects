// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function zusageAngebotLieferantSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "angebot-zusage-lieferant-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "angebot_zusage_lieferant_message",
          correlationKey: "angebot_zusage_lieferant_erhalten_key",
          variables: {
            start_event_reason: "zusage_angebot_erhalten",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  