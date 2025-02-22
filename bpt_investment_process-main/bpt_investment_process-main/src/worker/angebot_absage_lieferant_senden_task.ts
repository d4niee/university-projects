// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ablehnungAngebotLieferantSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "angebot-absage-lieferant-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "angebot-absage-lieferant-erhalten-message",
          correlationKey: "angebot_absage_lieferant_erhalten_key",
          variables: {
            start_event_reason: "absage_angebot_erhalten",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  