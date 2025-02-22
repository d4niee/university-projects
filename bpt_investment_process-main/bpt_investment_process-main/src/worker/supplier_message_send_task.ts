// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function startThrowingMessageSupplierWorker(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-lieferant-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung_lieferant_erhalten_message",
          correlationKey: "",
          variables: {
            start_event_reason: "angebot_erhalten",
            angebot_absage_lieferant_erhalten_key: "angebot_absage_lieferant_erhalten_key",
            angebot_zusage_lieferant_erhalten_key: "angebot_zusage_lieferant_erhalten_key",
            ausschreibung_absage_lieferant_key: "ausschreibung_absage_lieferant_key",
            ausschreibung_zusage_lieferant_key: "ausschreibung_zusage_lieferant_key",
          },
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  